#!/bin/bash

# ════════════════════════════════════════════
#  Sway Random Wallpaper on Startup
# ════════════════════════════════════════════

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Check if directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR not found!"
    exit 1
fi

# Get random wallpaper
WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) | shuf -n 1)

# Check if wallpaper found
if [[ -z "$WALLPAPER" ]]; then
    notify-send "Wallpaper Error" "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Generate colors with wal
#wal -i "$WALLPAPER" -n

# Set wallpaper
swaymsg output "*" bg "$WALLPAPER" fill

# fuzzel
#cat ~/.cache/wal/colors-fuzzel.ini > ~/.config/fuzzel/colors.ini

# Notification
notify-send "Wallpaper Changed" "$(basename "$WALLPAPER")"
