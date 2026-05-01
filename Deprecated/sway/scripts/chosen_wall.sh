#!/bin/bash

# ════════════════════════════════════════════
#  Sway Wallpaper Picker with Fuzzel
# ════════════════════════════════════════════

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

# Check if directory exists
if [[ ! -d "$WALLPAPER_DIR" ]]; then
    notify-send "Wallpaper Error" "Directory $WALLPAPER_DIR not found!"
    exit 1
fi

# Get all wallpapers
WALLPAPERS=$(find "$WALLPAPER_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" \) -printf "%f\n" | sort)

# Check if wallpapers found
if [[ -z "$WALLPAPERS" ]]; then
    notify-send "Wallpaper Error" "No images found in $WALLPAPER_DIR"
    exit 1
fi

# Show menu with fuzzel
CHOICE=$(echo "$WALLPAPERS" | fuzzel --dmenu --prompt="Choose Wallpaper: ")

# If ESC pressed or cancelled
[[ -z "$CHOICE" ]] && exit 0

# Full path to selected wallpaper
SELECTED_WALLPAPER="$WALLPAPER_DIR/$CHOICE"

# Set the theme
#wal -i "$SELECTED_WALLPAPER" -n

# Set wallpaper
swaymsg output "*" bg "$SELECTED_WALLPAPER" fill

# fuzzel
#cat ~/.cache/wal/colors-fuzzel.ini > ~/.config/fuzzel/colors.ini

# Notification
notify-send "Wallpaper Changed" "$CHOICE"
