#!/bin/bash

CONFIG_URL="https://raw.githubusercontent.com/dev-dhrubo-teamx/tvseries-plxbd/main/tvseries.txt"
BASE_DIR="$HOME/TV-Series"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR" || exit 1

current_series=""
current_season=""

url_decode() {
    printf '%b\n' "${1//%/\\x}"
}

curl -fsSL "$CONFIG_URL" | while IFS= read -r line; do
    line="${line//$'\r'/}"

    [[ -z "$line" || "$line" =~ ^# ]] && continue

    if [[ "$line" =~ ^\[Series:\ (.+)\]$ ]]; then
        current_series="${BASH_REMATCH[1]}"
        mkdir -p "$current_series"
        echo "📁 Series: $current_series"
        continue
    fi

    if [[ "$line" =~ ^\[Season:\ (.+)\]$ ]]; then
        current_season="${BASH_REMATCH[1]}"
        mkdir -p "$current_series/$current_season"
        echo "  📂 Season: $current_season"
        continue
    fi

    url="$line"
    raw_name=$(basename "${url%%\?*}")
    filename=$(url_decode "$raw_name")
    target="$current_series/$current_season/$filename"

    if [[ -f "$target" ]]; then
        echo "    ⏭️  Skipped: $filename"
    else
        echo "    ⬇️  Downloading: $filename"
        wget -c -O "$target" "$url"
    fi

done
