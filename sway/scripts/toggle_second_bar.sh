#!/bin/bash
# =======================
# Toggle Second Bar Config
# =======================

SOURCE_FILE="$HOME/.config/sway/scripts/assets/second_bar_template.conf"
TARGET_FILE="$HOME/.config/sway/local.d/second_bar.conf"

# Check if target file is empty or doesn't exist
if [ ! -s "$TARGET_FILE" ]; then
    # File is empty or doesn't exist -> Copy content
    cat "$SOURCE_FILE" > "$TARGET_FILE"
    notify-send "Sway Bar" "Second bar enabled" -t 2000
else
    # File has content -> Empty it
    > "$TARGET_FILE"
    notify-send "Sway Bar" "Second bar disabled" -t 2000
fi

# Reload sway
swaymsg reload
