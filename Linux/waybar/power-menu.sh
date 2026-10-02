#!/bin/bash

THEME="$HOME/.config/waybar/main-menu.rasi"

choice=$(printf '%s\n' \
    "󰐥   Shutdown" \
    "󰜉   Reboot" \
    "󰒲   Sleep" \
    "󰤄   Hibernate" \
    "󰌾   Lock" \
    "󰗽   Logout" \
    "󰁍   Back" \
    | rofi -dmenu -i -p "Power" -theme "$THEME")

case "$choice" in
    *Shutdown)
        systemctl poweroff
        ;;
    *Reboot)
        systemctl reboot
        ;;
    *Sleep)
        systemctl suspend
        ;;
    *Hibernate)
        systemctl hibernate
        ;;
    *Lock)
        if command -v hyprlock >/dev/null 2>&1; then
            hyprlock
        elif command -v loginctl >/dev/null 2>&1; then
            loginctl lock-session
        fi
        ;;
    *Logout)
        hyprctl dispatch exit
        ;;
    *Back)
        "$HOME/.config/waybar/main-menu.sh"
        ;;
esac
