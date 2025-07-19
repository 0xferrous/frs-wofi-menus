#!/usr/bin/env bash

# DeFiLlama Common Functions Library
# Shared functionality for wofi and rofi protocol selectors

set -euo pipefail

# Configuration
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/frs-wofi-menus"
CACHE_FILE="$CACHE_DIR/protocols.json"
CACHE_MAX_AGE=$((24 * 60 * 60))  # 24 hours in seconds
API_URL="https://api.llama.fi/lite/protocols2?b=2"

# Create cache directory if it doesn't exist
mkdir -p "$CACHE_DIR"

# Function to check if cache is valid
is_cache_valid() {
    if [[ ! -f "$CACHE_FILE" ]]; then
        return 1
    fi

    local cache_age=$(($(date +%s) - $(stat -c %Y "$CACHE_FILE" 2>/dev/null || echo 0)))
    [[ $cache_age -lt $CACHE_MAX_AGE ]]
}

# Function to fetch data from API
fetch_protocols() {
    echo "Fetching protocol data..." >&2
    if curl -s --fail "$API_URL" -o "$CACHE_FILE.tmp"; then
        mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        echo "Protocol data updated successfully" >&2
    else
        echo "Error: Failed to fetch protocol data" >&2
        rm -f "$CACHE_FILE.tmp"
        return 1
    fi
}

# Function to get protocol names
get_protocol_names() {
    jq -r '.protocols[] | select(.name != null and .url != null) | .name' "$CACHE_FILE" 2>/dev/null
}

# Function to get URL for a selected protocol
get_protocol_url() {
    local selected="$1"
    jq -r --arg name "$selected" '.protocols[] |
        select(.name == $name) |
        .url' "$CACHE_FILE" 2>/dev/null | head -1
}

# Function to ensure cache is available
ensure_cache() {
    if ! is_cache_valid; then
        fetch_protocols || {
            # If fetch fails and we have old cache, use it
            if [[ -f "$CACHE_FILE" ]]; then
                echo "Warning: Using cached data (failed to update)" >&2
            else
                echo "Error: No cached data available" >&2
                exit 1
            fi
        }
    fi
}

# Function to open URL in browser
open_protocol() {
    local selected="$1"
    local url
    url=$(get_protocol_url "$selected")

    if [[ -n "$url" ]]; then
        xdg-open "$url" &
        echo "Opening: $selected ($url)" >&2
    else
        echo "Error: Could not find URL for: $selected" >&2
        exit 1
    fi
}

# Function to handle refresh command
handle_refresh() {
    rm -f "$CACHE_FILE"
    fetch_protocols
}

# Function to show cache info
show_cache_info() {
    if [[ -f "$CACHE_FILE" ]]; then
        echo "Cache file: $CACHE_FILE"
        echo "Cache age: $(( ($(date +%s) - $(stat -c %Y "$CACHE_FILE")) / 3600 )) hours"
        echo "Total protocols: $(jq '.protocols | length' "$CACHE_FILE" 2>/dev/null || echo "unknown")"
    else
        echo "No cache file found"
    fi
}

# Function to show help
show_help() {
    local script_name="$1"
    local menu_tool="$2"
    cat << EOF
DeFiLlama $menu_tool Selector

Usage: $script_name [OPTIONS]

Options:
  --refresh, -r     Force refresh the protocol cache
  --cache-info, -i  Show cache information
  --help, -h        Show this help message

The selector caches protocol data for 24 hours in:
  $CACHE_DIR

Examples:
  $script_name              # Show protocol selector
  $script_name --refresh    # Update cache and show selector
  $script_name --cache-info # Display cache status
EOF
}