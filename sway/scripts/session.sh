#!/bin/sh

chosen=$(printf "  Lock\n  Log out\n  Suspend\n  Hibernate\n  Reboot\n  Power off" \
  | fuzzel --dmenu )

case "$chosen" in
  "  Lock")       swaylock ;;
  "  Log out")    swaymsg exit ;;
  "  Suspend")    loginctl suspend ;;
  "  Hibernate")  loginctl hibernate ;;
  "  Reboot")     loginctl reboot ;;
  "  Power off")  loginctl poweroff ;;
esac
