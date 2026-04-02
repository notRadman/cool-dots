#!/bin/bash
# =======================
# Toggle Second Bar Config
# =======================

SOURCE_FILE="$HOME/.config/sway/scripts/assets/gaps_template.conf"
TARGET_FILE="$HOME/.config/sway/local.d/gaps.conf"

# Check if target file is empty or doesn't exist
if [ ! -s "$TARGET_FILE" ]; then
    # File is empty or doesn't exist -> Copy content
    cat "$SOURCE_FILE" > "$TARGET_FILE"
    notify-send "Sway Gaps" "Gaps enabled, move the windows to see it" -t 2000
else
    # File has content -> Empty it
    > "$TARGET_FILE"
    notify-send "Sway Gaps" "Gaps disabled" -t 2000
fi

# Reload sway
swaymsg reload
