#!/bin/sh
# Language switcher

swaymsg input type:keyboard xkb_switch_layout next

LAYOUT=$(swaymsg -t get_inputs -r | \
    jq -r '[.[] | select(.type == "keyboard")] | first | .xkb_active_layout_name')

notify-send "Layout" "$LAYOUT" \
    -t 1500 \
    -h string:x-canonical-private-synchronous:keyboard-layout

