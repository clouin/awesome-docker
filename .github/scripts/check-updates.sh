#!/bin/bash
set -euo pipefail

# ============================================================================
# Check for Updates Script
# ============================================================================
# This script checks all projects in config.yaml for version updates and
# outputs a JSON array of projects needing updates to $GITHUB_OUTPUT

# Config file is in the same directory as this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/config.yaml"

# ============================================================================
# Utility Functions
# ============================================================================

log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $*" >&2
}

retry_cmd() {
    local cmd="$1"
    local retries=5
    local base_wait=2
    local count=0
    local result=""

    while [ $count -lt $retries ]; do
        if result=$(eval "$cmd" 2>&1); then
            if [ -n "$result" ] && [ "$result" != "null" ]; then
                echo "$result"
                return 0
            fi
        fi
        count=$((count + 1))
        local wait=$((base_wait * (1 << (count - 1))))
        if echo "$result" | grep -q "429"; then
            wait=60
            log "Rate limit hit, waiting ${wait}s..."
        fi
        log "Retry ${count}/${retries} after ${wait}s..."
        sleep $wait
    done
    echo "Failed after ${retries} retries: $result" >&2
    return 1
}

filter_stable_versions() {
    # Only keep semantic versions (e.g., 0.10.8), filter out pre-release (e.g., 0.10.9-alpha.3)
    grep -E '^[0-9]+(\.[0-9]+)+$'
}

get_version() {
    local source_type="$1"
    local repo="$2"
    local tag_prefix="$3"
    local stable_only="$4"
    local versions=""

    case "$source_type" in
        "git_tags")
            versions=$(git ls-remote --tags --refs "https://github.com/$repo.git" 2>/dev/null | \
                awk '{print $2}' | sed 's|refs/tags/||' | \
                grep -E '^V?[0-9]+(\.[0-9]+)*(-[a-z0-9]+)?$' | sed 's/^[vV]//' | \
                sort -V)
            if [ "$stable_only" = "true" ]; then
                versions=$(echo "$versions" | filter_stable_versions)
            fi
            echo "$versions" | tail -n1
            ;;
        "github_api")
            if [ -n "$tag_prefix" ]; then
                # Fetch API response with HTTP status code
                local api_response
                api_response=$(curl -s -w "\n%{http_code}" --retry 3 --retry-delay 1 --connect-timeout 10 \
                    "https://api.github.com/repos/$repo/releases" 2>/dev/null)
                local http_code
                http_code=$(echo "$api_response" | tail -n1)
                local body
                body=$(echo "$api_response" | sed '$d')

                # Validate response is a JSON array
                if [ "$http_code" != "200" ] || [ -z "$body" ] || ! echo "$body" | jq -e 'type == "array"' >/dev/null 2>&1; then
                    log "  Error: GitHub API returned invalid response (HTTP $http_code) for $repo"
                    return 1
                fi

                versions=$(echo "$body" | jq -r --arg prefix "$tag_prefix" '
                    [.[].tag_name] |
                    map(select(startswith($prefix))) |
                    map(gsub("^" + $prefix; "")) |
                    sort_by(. | split(".") | map(tonumber? // 0))
                ')
                if [ "$stable_only" = "true" ]; then
                    versions=$(echo "$versions" | jq -r 'map(select(test("^[0-9]+(\\.[0-9]+)+$"))) | last // empty')
                else
                    versions=$(echo "$versions" | jq -r 'last // empty')
                fi
                echo "$versions"
            else
                # Determine API endpoint
                local api_url
                if [ "$stable_only" = "true" ]; then
                    api_url="https://api.github.com/repos/$repo/releases"
                else
                    api_url="https://api.github.com/repos/$repo/releases/latest"
                fi

                # Fetch API response with HTTP status code
                local api_response
                api_response=$(curl -s -w "\n%{http_code}" --retry 3 --retry-delay 1 --connect-timeout 10 "$api_url" 2>/dev/null)
                local http_code
                http_code=$(echo "$api_response" | tail -n1)
                local body
                body=$(echo "$api_response" | sed '$d')

                # Validate response
                if [ "$http_code" != "200" ] || [ -z "$body" ]; then
                    log "  Error: GitHub API returned invalid response (HTTP $http_code) for $repo"
                    return 1
                fi

                if [ "$stable_only" = "true" ]; then
                    echo "$body" | jq -r '
                        [.[].tag_name] |
                        map(gsub("^v"; "")) |
                        map(select(test("^[0-9]+(\\.[0-9]+)+$"))) |
                        sort_by(. | split(".") | map(tonumber)) |
                        last // empty
                    '
                else
                    echo "$body" | jq -r '.tag_name // empty' | grep -oP '\d+(\.\d+)+' | head -1
                fi
            fi
            ;;
        "docker_hub")
            result=$(curl -s --retry 3 --retry-delay 1 --connect-timeout 10 \
                "https://hub.docker.com/v2/repositories/$repo/tags" 2>/dev/null)
            if [ -n "$result" ] && echo "$result" | jq -e '.results' >/dev/null 2>&1; then
                version=$(echo "$result" | jq -r '.results[].name' 2>/dev/null | \
                    grep -oP '^v?\d+\.\d+(\.\d+)?(-[a-z0-9]+)?$' | \
                    sed 's/^v//' | sort -V | tail -n 1)
                if [ -n "$version" ]; then
                    echo "$version"
                fi
            fi
            ;;
        "acr")
            if command -v skopeo &>/dev/null; then
                skopeo list-tags "docker://$repo" 2>/dev/null | \
                    jq -r '[.Tags[] | select(. != "latest")] | sort_by(. | split(".") | map(tonumber)) | last'
            else
                echo "Error: skopeo is not installed" >&2
                return 1
            fi
            ;;
        *)
            echo "Unknown source type: $source_type" >&2
            return 1
            ;;
    esac
}

# ============================================================================
# Main Logic
# ============================================================================

log "=== Starting check for updates ==="

# Check dependencies
for cmd in curl jq yq; do
    if ! command -v "$cmd" &>/dev/null; then
        log "Error: $cmd is not installed"
        exit 1
    fi
done

# Ensure config exists
if [ ! -f "$CONFIG_FILE" ]; then
    log "Error: Config file not found: $CONFIG_FILE"
    exit 1
fi

UPDATES_JSON="[]"

# Iterate through all projects
while IFS= read -r project_json; do
    PROJECT_NAME=$(echo "$project_json" | jq -r '.project_name')
    log "Checking project: $PROJECT_NAME"

    REPO_CURRENT=$(echo "$project_json" | jq -r '.repo_current')
    SOURCE_LATEST=$(echo "$project_json" | jq -r '.version_source.latest')
    SOURCE_CURRENT=$(echo "$project_json" | jq -r '.version_source.current')
    VERSION_TYPE=$(echo "$project_json" | jq -r '.version_type')

    # Extract optional config from version_source
    TAG_PREFIX=$(echo "$project_json" | jq -r '.version_source.tag_prefix // ""')
    STABLE_ONLY=$(echo "$project_json" | jq -r '.version_source.stable_only // "false"')

    log "  Config: latest=$SOURCE_LATEST, current=$SOURCE_CURRENT, tag_prefix='$TAG_PREFIX', stable_only=$STABLE_ONLY"

    # Handle multi_repo_match (version_type: multi_repo_match)
    if [ "$VERSION_TYPE" = "multi_repo_match" ]; then
        # Check if repo_latest is an array
        if ! echo "$project_json" | jq -e '.repo_latest | type == "array"' >/dev/null; then
            log "  Error: repo_latest must be an array for multi_repo_match, skipping"
            continue
        fi

        VERSIONS=()
        ALL_VERSIONS_FETCHED=true
        while IFS= read -r repo; do
            version=$(retry_cmd "get_version \"$SOURCE_LATEST\" \"$repo\" \"$TAG_PREFIX\" \"$STABLE_ONLY\"")
            if [ -z "$version" ]; then
                log "  Failed to get version for repo '$repo'"
                ALL_VERSIONS_FETCHED=false
                break
            fi
            VERSIONS+=("$version")
            log "  $repo: $version"
        done < <(echo "$project_json" | jq -r '.repo_latest[]')

        if ! $ALL_VERSIONS_FETCHED; then
            continue
        fi

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
            log "  Warning: Repository versions do not match, skipping"
            continue
        fi
        LATEST_VERSION="$FIRST_VERSION"
    else
        # Standard single repository version check
        REPO_LATEST=$(echo "$project_json" | jq -r '.repo_latest')
        LATEST_VERSION=$(retry_cmd "get_version \"$SOURCE_LATEST\" \"$REPO_LATEST\" \"$TAG_PREFIX\" \"$STABLE_ONLY\"") || {
            log "  Version check failed for latest repo"
            continue
        }
        log "  Latest: $REPO_LATEST -> $LATEST_VERSION"
    fi

    CURRENT_VERSION=$(get_version "$SOURCE_CURRENT" "$REPO_CURRENT" "" "false")
    if [ -z "$CURRENT_VERSION" ]; then
        log "  Current: $REPO_CURRENT -> (not found, image may not exist yet)"
    else
        log "  Current: $REPO_CURRENT -> $CURRENT_VERSION"
    fi

    # Check if update is needed
    if [ -n "$CURRENT_VERSION" ] && [ -n "$LATEST_VERSION" ] && [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
        log "  [UPDATE NEEDED] $CURRENT_VERSION -> $LATEST_VERSION"
        FILE_PATH=$(echo "$project_json" | jq -r '.file_path')
        REPOSITORY=$(echo "$project_json" | jq -r '.repository')
        PLATFORMS=$(echo "$project_json" | jq -r '.platforms')

        # Create JSON object for the update
        UPDATE_OBJ=$(jq -n \
            --arg file_path "$FILE_PATH" \
            --arg repository "$REPOSITORY" \
            --arg tag "$LATEST_VERSION" \
            --arg platforms "$PLATFORMS" \
            '{file_path: $file_path, repository: $repository, tag: $tag, platforms: $platforms}')
        UPDATES_JSON=$(echo "$UPDATES_JSON" | jq -c --argjson obj "$UPDATE_OBJ" '. + [$obj]')
    else
        if [ -z "$CURRENT_VERSION" ]; then
            log "  [PENDING] No existing image found"
        else
            log "  [UP TO DATE]"
        fi
    fi
    log ""
done < <(yq eval '.projects[]' -o=json "$CONFIG_FILE" | jq -c '.')

log "=== Check complete ==="

# Output updates_needed to GITHUB_OUTPUT
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    # Ensure clean JSON output without extra whitespace
    printf '%s=%s\n' 'updates_needed' "$UPDATES_JSON" >> "$GITHUB_OUTPUT"
fi