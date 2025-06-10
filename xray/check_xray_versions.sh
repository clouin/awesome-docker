#!/bin/bash

# Fetch the latest release tag from the GitHub repository
REPO="XTLS/Xray-core"
DOCKER_REPO="jerryin/xray"
LATEST_DOCKER_REPO="teddysun/xray"

# Retry helper function
retry_cmd() {
  local retries=3
  local wait=2
  local count=0
  local result

  while [ $count -lt $retries ]; do
    result=$($1)
    if [ -n "$result" ]; then
      echo "$result"
      return 0
    fi
    count=$((count + 1))
    sleep $wait
  done
  return 1
}

# Get latest version from Docker Hub (teddysun)
get_latest_docker_version() {
  curl -s "https://hub.docker.com/v2/repositories/$LATEST_DOCKER_REPO/tags" |
    jq -r '.results[].name' |
    grep -oP '^\d+\.\d+\.\d+$' |
    sort -V |
    tail -n 1
}

# Get the latest GitHub release tag (strip leading "v" or "V")
get_latest_version() {
  curl -s "https://api.github.com/repos/$REPO/releases/latest" |
    grep -Po '"tag_name": "\K.*?(?=")' |
    sed 's/^[vV]//'
}

# Get the highest semver tag from Docker Hub (your repo)
get_current_version() {
  curl -s "https://hub.docker.com/v2/repositories/$DOCKER_REPO/tags" |
    jq -r '.results[].name' |
    grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' |
    sort -V |
    tail -n1
}

# Fetch versions
LATEST_DOCKER_VERSION=$(retry_cmd "get_latest_docker_version")
LATEST_VERSION=$(retry_cmd "get_latest_version")
CURRENT_VERSION=$(retry_cmd "get_current_version")

# Output for GitHub Actions
echo "latest_docker_version=$LATEST_DOCKER_VERSION"
echo "latest_version=$LATEST_VERSION"
echo "current_version=$CURRENT_VERSION"

# Check if update is needed
if [[ "$LATEST_DOCKER_VERSION" == "$LATEST_VERSION" && "$LATEST_VERSION" != "$CURRENT_VERSION" ]]; then
  echo "update_needed=true"
else
  echo "update_needed=false"
fi
