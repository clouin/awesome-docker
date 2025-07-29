#!/bin/bash

# Unified version checking script for all projects
# Usage: ./check_project_version.sh <project_name>

PROJECT_NAME="$1"

if [ -z "$PROJECT_NAME" ]; then
  echo "Usage: $0 <project_name>"
  echo "Available projects:"
  yq eval '.projects[].project_name' config.yaml
  exit 1
fi

# Check and install required dependencies
check_dependencies() {
  local dependencies=("curl" "jq" "skopeo" "yq")
  local missing=()
  local pkg_manager=""

  # Detect package manager
  if command -v apt-get &>/dev/null; then
    pkg_manager="apt-get"
  elif command -v yum &>/dev/null; then
    pkg_manager="yum"
  elif command -v dnf &>/dev/null; then
    pkg_manager="dnf"
  else
    echo "Unsupported package manager. Please install dependencies manually."
    return 1
  fi

  # Check which dependencies are missing
  for dep in "${dependencies[@]}"; do
    if ! command -v "$dep" &>/dev/null; then
      missing+=("$dep")
    fi
  done

  # Install missing dependencies
  if [ ${#missing[@]} -gt 0 ]; then
    echo "Installing missing dependencies: ${missing[*]}"

    # Always install yq via binary for reliability
    if [[ " ${missing[*]} " =~ " yq " ]]; then
      echo "Installing yq from GitHub release..."

      # Detect architecture
      arch=$(uname -m)
      case $arch in
        x86_64) bin_arch="amd64" ;;
        aarch64) bin_arch="arm64" ;;
        armv7l) bin_arch="arm" ;;
        *)
          echo "Unsupported architecture: $arch. Please install yq manually."
          exit 1
          ;;
      esac

      # Use curl if available, else wget
      if command -v curl &>/dev/null; then
        sudo curl -L "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${bin_arch}" -o /usr/bin/yq
      elif command -v wget &>/dev/null; then
        sudo wget "https://github.com/mikefarah/yq/releases/latest/download/yq_linux_${bin_arch}" -O /usr/bin/yq
      else
        echo "Error: curl or wget required to install yq"
        exit 1
      fi

      sudo chmod +x /usr/bin/yq
      # Remove yq from missing list
      missing=("${missing[@]/yq/}")
    fi

    # Install remaining dependencies using package manager
    if [ ${#missing[@]} -gt 0 ]; then
      if [ "$pkg_manager" = "apt-get" ] || [ "$pkg_manager" = "apt" ]; then
        sudo apt-get update
        sudo apt-get install -y "${missing[@]}" || {
          echo "Failed to install packages: ${missing[*]}"
          exit 1
        }
      elif [ "$pkg_manager" = "yum" ]; then
        sudo yum install -y "${missing[@]}" || {
          echo "Failed to install packages: ${missing[*]}"
          exit 1
        }
      elif [ "$pkg_manager" = "dnf" ]; then
        sudo dnf install -y "${missing[@]}" || {
          echo "Failed to install packages: ${missing[*]}"
          exit 1
        }
      fi
    fi

    # Verify all dependencies are installed
    for dep in "${dependencies[@]}"; do
      if ! command -v "$dep" &>/dev/null; then
        echo "Error: Failed to install $dep. Please install it manually."
        exit 1
      fi
    done
  fi
}

# Ensure dependencies are installed
check_dependencies

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file $CONFIG_FILE not found"
  exit 1
fi

# Retry command function (copied from check_repo_updates.sh)
retry_cmd() {
  local cmd="$1"
  local retries=3
  local wait=2
  local count=0
  local result=""

  while [ $count -lt $retries ]; do
    if result=$(eval "$cmd" 2>/dev/null); then
      if [ -n "$result" ] && [ "$result" != "null" ]; then
        echo "$result"
        return 0
      fi
    fi
    count=$((count + 1))
    sleep $wait
  done
  return 1
}

# Unified function to get version based on source type (copied from check_repo_updates.sh)
get_version() {
  local source_type="$1"
  local repo="$2"

  case "$source_type" in
    "git_tags")
      local repo_url="https://github.com/$repo.git"
      git ls-remote --tags --refs "$repo_url" |
        awk '{print $2}' | sed 's|refs/tags/||' |
        grep -E '^V?[0-9]+(\.[0-9]+)*$' | sed 's/^[vV]//' |
        sort -V | tail -n1
      ;;
    "github_api")
      curl -s "https://api.github.com/repos/$repo/releases/latest" |
        jq -r '.tag_name' | grep -oP '\d+(\.\d+)+' | head -1
      ;;
    "docker_hub")
      curl -s "https://hub.docker.com/v2/repositories/$repo/tags" |
        jq -r '.results[].name' |
        grep -oP '^v?\d+\.\d+(\.\d+)?(-[a-z0-9]+)?$' | sed 's/^v//' |
        sort -V | tail -n 1
      ;;
    "acr")
      skopeo list-tags docker://"$repo" |
        jq -r '[.Tags[] | select(. != "latest")] | sort_by(. | split(".") | map(tonumber)) | last'
      ;;
    *)
      echo "Unknown source type: $source_type" >&2
      return 1
      ;;
  esac
}

# Find project in config
PROJECT_CONFIG=$(yq eval -o=json '.projects[] | select(.project_name == "'"$PROJECT_NAME"'")' "$CONFIG_FILE")

if [ -z "$PROJECT_CONFIG" ]; then
  echo "Error: Project '$PROJECT_NAME' not found in config.yaml"
  echo "Available projects:"
  yq eval '.projects[].project_name' config.yaml
  exit 1
fi

# Extract project configuration
REPO_LATEST=$(echo "$PROJECT_CONFIG" | jq -r '.repo_latest')
REPO_CURRENT=$(echo "$PROJECT_CONFIG" | jq -r '.repo_current')
SOURCE_LATEST=$(echo "$PROJECT_CONFIG" | jq -r '.version_source.latest')
SOURCE_CURRENT=$(echo "$PROJECT_CONFIG" | jq -r '.version_source.current')
VERSION_TYPE=$(echo "$PROJECT_CONFIG" | jq -r '.version_type')

echo "Checking project: $PROJECT_NAME"
echo "Latest source: $SOURCE_LATEST ($REPO_LATEST)"
echo "Current source: $SOURCE_CURRENT ($REPO_CURRENT)"

# Handle multi-repository version matching
if [ "$VERSION_TYPE" = "multi_repo_match" ]; then
  # Check if repo_latest is an array
  if ! echo "$PROJECT_CONFIG" | jq -e '.repo_latest | type == "array"' >/dev/null; then
    echo "Error: repo_latest must be an array for multi_repo_match"
    exit 1
  fi

  # Get repository list
  readarray -t REPOS < <(echo "$PROJECT_CONFIG" | jq -r '.repo_latest[]')

  # Get versions for all repositories
  VERSIONS=()
  for repo in "${REPOS[@]}"; do
    version=$(retry_cmd "get_version \"$SOURCE_LATEST\" \"$repo\"")
    if [ -z "$version" ]; then
      echo "Error: Failed to get version for $repo"
      exit 1
    fi
    VERSIONS+=("$version")
  done

  # Check if all versions match
  FIRST_VERSION="${VERSIONS[0]}"
  ALL_MATCH=true
  for ver in "${VERSIONS[@]}"; do
    if [ "$ver" != "$FIRST_VERSION" ]; then
      ALL_MATCH=false
      break
    fi
  done

  if ! $ALL_MATCH; then
    echo "Warning: Repository versions do not match, skipping update check"
    echo "Repositories: ${REPOS[*]}"
    echo "Versions: ${VERSIONS[*]}"
    echo "latest_version="
    echo "current_version="
    echo "update_needed=false"
    exit 0
  fi

  LATEST_VERSION="$FIRST_VERSION"
else
  # Standard handling for single repository
  LATEST_VERSION=$(retry_cmd "get_version \"$SOURCE_LATEST\" \"$REPO_LATEST\"")
fi

# Get current version using unified function
CURRENT_VERSION=$(retry_cmd "get_version \"$SOURCE_CURRENT\" \"$REPO_CURRENT\"")

# Check if version fetch succeeded
if [ -z "$LATEST_VERSION" ] || [ -z "$CURRENT_VERSION" ]; then
  echo "Error: Failed to get version information"
  echo "Latest Version: $LATEST_VERSION"
  echo "Current Version: $CURRENT_VERSION"
  echo "latest_version="
  echo "current_version="
  echo "update_needed=false"
  exit 1
fi

# Extract additional project configuration
FILE_PATH=$(echo "$PROJECT_CONFIG" | jq -r '.file_path')
REPOSITORY=$(echo "$PROJECT_CONFIG" | jq -r '.repository')
PLATFORMS=$(echo "$PROJECT_CONFIG" | jq -r '.platforms')

# Output for GitHub Actions
echo "latest_version=$LATEST_VERSION"
echo "current_version=$CURRENT_VERSION"
echo "file_path=$FILE_PATH"
echo "repository=$REPOSITORY"
echo "platforms=$PLATFORMS"

# Compare versions
if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
  echo "update_needed=true"
else
  echo "update_needed=false"
fi
