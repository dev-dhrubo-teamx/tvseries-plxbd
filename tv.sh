#!/bin/bash

CONFIG_URL="https://raw.githubusercontent.com/dev-dhrubo-teamx/tvseries-plxbd/main/tvseries.txt"
BASE_DIR="$HOME/TV-Series"

mkdir -p "$BASE_DIR"
cd "$BASE_DIR" || exit 1

current_series=""
current_season=""

curl -fsSL "$CONFIG_URL" | while IFS= read -r line; do
    line="${line//$'\r'/}"  # windows line ending fix

    # skip empty or comment
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

    # episode link
    url="$line"
    filename=$(basename "${url%%\?*}")
    target="$current_series/$current_season/$filename"

    if [[ -f "$target" ]]; then
        echo "    ⏭️  Skipped: $filename"
    else
        echo "    ⬇️  Downloading: $filename"
        wget -c -O "$target" "$url"
    fi

done
