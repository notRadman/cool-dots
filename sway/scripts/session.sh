#!/bin/sh

chosen=$(printf "  Power off\n  Reboot\n  Log out\n  Suspend\n  Hibernate\n  Lock" \
  | fuzzel --dmenu )

case "$chosen" in
  "  Lock")       swaylock ;;
  "  Log out")    swaymsg exit ;;
  "  Suspend")    loginctl suspend ;;
  "  Hibernate")  loginctl hibernate ;;
  "  Reboot")     loginctl reboot ;;
  "  Power off")  loginctl poweroff ;;
esac
