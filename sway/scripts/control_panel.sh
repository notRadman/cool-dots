#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════╗
# ║                    settings-launcher                             ║
# ║              A simple control panel launcher                     ║
# ╚══════════════════════════════════════════════════════════════════╝

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#                  CONFIG
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Menu launcher: rofi | fuzzel | dmenu | bemenu | wofi
LAUNCHER="fuzzel"

# Browser for opening URLs (leave as xdg-open to use system default)
BROWSER="xdg-open"
BROWSER_FALLBACK="firefox"

# Menu prompt title
MENU_TITLE="Settings"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#                  ENTRIES
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Format:
#   "Display Name | command or URL | icon name or path | fallback emoji"
#
#   - Regular command:  pavucontrol
#   - Open a URL:       url:http://localhost:631
#   - No icon?          leave the icon field empty: ""
#   - Emoji is shown in launchers that don't support icons (dmenu/bemenu/fuzzel)
#   - Special commands: __help__ | __vnstat__
#

ENTRIES=(
    #  Display Name            | Command                       | Icon (theme name or path)       | Emoji
    "Audio Settings            | pavucontrol                   | audio-volume-high               | 🔊"
    "Theme Settings            | nwg-look                      | preferences-desktop-theme       | 🎨"
#    "Display Settings          | wdisplays                     | preferences-desktop-display     | 🖥️"
    "Bluetooth                 | blueman-manager               | bluetooth                       | 🔵"
    "Network                   | nm-connection-editor          | network-manager                 | 🌐"
    "Printer (CUPS)            | url:http://localhost:631      | printer                         | 🖨️"
    "File Sync (Syncthing)     | url:http://localhost:8384     | syncthing                       | 🔄"
#    "Keyboard Settings         | ibus-setup                    | input-keyboard                  | ⌨️"
#    "File Manager              | thunar                        | system-file-manager             | 📁"
    "Audio Patchbay (Helvum)   | helvum                        | audio-card                      | 🎛️"
    "Network Usage             | __vnstat__                    |                                 |   "
    "Help                      | __help__                      |                                 |   "
)

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#          LAUNCHER OPTIONS (optional)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

ROFI_EXTRA_ARGS="-theme-str 'window {width: 400px;}'"
#FUZZEL_EXTRA_ARGS="--width 35"
DMENU_EXTRA_ARGS="-l 15 -i"
BEMENU_EXTRA_ARGS="-l 15 -i --tb '#285577' --tf '#ffffff'"
WOFI_EXTRA_ARGS="--width 400 --height 400"

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#          DO NOT EDIT BELOW THIS LINE
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

notify() {
    local urgency="${1:-normal}"
    local summary="$2"
    local body="${3:-}"
    if command -v notify-send &>/dev/null; then
        notify-send -u "$urgency" "Settings Launcher" "$summary${body:+: $body}"
    else
        echo "[settings-launcher] $summary $body" >&2
    fi
}

launcher_exists() { command -v "$1" &>/dev/null; }

LAUNCHERS_PRIORITY=(rofi wofi fuzzel bemenu dmenu)

resolve_launcher() {
    if launcher_exists "$LAUNCHER"; then
        echo "$LAUNCHER"; return
    fi
    notify "normal" "Launcher '$LAUNCHER' not found, trying fallback..."
    for l in "${LAUNCHERS_PRIORITY[@]}"; do
        if launcher_exists "$l"; then
            echo "$l"; return
        fi
    done
    notify "critical" "No launcher found!" "Install one of: rofi fuzzel dmenu bemenu wofi"
    exit 1
}

build_menu() {
    local active_launcher="$1"
    for entry in "${ENTRIES[@]}"; do
        local name icon emoji
        name=$(echo "$entry"  | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1}')
        icon=$(echo "$entry"  | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $3); print $3}')
        emoji=$(echo "$entry" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $4); print $4}')

        case "$active_launcher" in
            rofi|wofi)
                if [[ -n "$icon" ]]; then
                    printf '%s\0icon\x1f%s\n' "$name" "$icon"
                else
                    printf '%s\n' "$name"
                fi
                ;;
            *)
                if [[ -n "$emoji" ]]; then
                    printf '%s %s\n' "$emoji" "$name"
                else
                    printf '%s\n' "$name"
                fi
                ;;
        esac
    done
}

build_help() {
    for entry in "${ENTRIES[@]}"; do
        local name cmd bin
        name=$(echo "$entry" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1}')
        cmd=$(echo "$entry"  | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')

        # skip special commands
        [[ "$cmd" == "__help__"   ]] && continue
        [[ "$cmd" == "__vnstat__" ]] && continue

        if [[ "$cmd" == url:* ]]; then
            bin="${cmd#url:}"
        else
            bin=$(awk '{print $1}' <<< "$cmd")
        fi

        printf '%s  →  %s\n' "$name" "$bin"
    done
}

run_launcher() {
    local active_launcher="$1"
    local menu_input="$2"
    local prompt="${3:-$MENU_TITLE}"

    case "$active_launcher" in
        rofi)
            echo "$menu_input" | eval rofi -dmenu -i -p "\"$prompt\"" "$ROFI_EXTRA_ARGS"
            ;;
        fuzzel)
            echo "$menu_input" | eval fuzzel --dmenu "$FUZZEL_EXTRA_ARGS"
            ;;
        dmenu)
            echo "$menu_input" | eval dmenu "$DMENU_EXTRA_ARGS" -p "\"$prompt\""
            ;;
        bemenu)
            echo "$menu_input" | eval bemenu "$BEMENU_EXTRA_ARGS" -p "\"$prompt\""
            ;;
        wofi)
            echo "$menu_input" | eval wofi --show dmenu "$WOFI_EXTRA_ARGS"
            ;;
    esac
}

show_help() {
    local active_launcher="$1"
    run_launcher "$active_launcher" "$(build_help)" "Help  —  Esc to go back" > /dev/null
}

show_vnstat() {
    local active_launcher="$1"
    if ! command -v vnstat &>/dev/null; then
        notify "critical" "vnstat not found" "install it with: xbps-install vnstat"
        return 1
    fi
    local output
    output=$(vnstat)
    run_launcher "$active_launcher" "$output" "Network Usage  —  Esc to go back" > /dev/null
}

find_command() {
    local selected="$1"
    local clean_selected
    clean_selected=$(echo "$selected" | sed 's/^[^[:alnum:]]*//; s/[[:space:]]*$//')

    for entry in "${ENTRIES[@]}"; do
        local name cmd emoji
        name=$(echo "$entry"  | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $1); print $1}')
        cmd=$(echo "$entry"   | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); print $2}')
        emoji=$(echo "$entry" | awk -F'|' '{gsub(/^[[:space:]]+|[[:space:]]+$/, "", $4); print $4}')

        if [[ "$selected"       == "$name"         ]] \
        || [[ "$clean_selected" == "$name"         ]] \
        || [[ "$selected"       == "$emoji $name"  ]] \
        || [[ "$selected"       == "$emoji  $name" ]]; then
            echo "$cmd"
            return
        fi
    done
}

execute_entry() {
    local cmd="$1"
    local active_launcher="$2"

    if [[ "$cmd" == "__help__" ]]; then
        show_help "$active_launcher"
        return
    fi

    if [[ "$cmd" == "__vnstat__" ]]; then
        show_vnstat "$active_launcher"
        return
    fi

    if [[ "$cmd" == url:* ]]; then
        open_url "${cmd#url:}"
        return
    fi

    local bin
    bin=$(awk '{print $1}' <<< "$cmd")

    if ! command -v "$bin" &>/dev/null; then
        notify "critical" "Program not found" "$bin"
        echo "[settings-launcher] ERROR: '$bin' not found in PATH" >&2
        return 1
    fi

    eval "$cmd" &>/dev/null &
    disown
}

open_url() {
    local url="$1"
    local opened=false

    if [[ -n "$BROWSER" ]] && command -v "$BROWSER" &>/dev/null; then
        "$BROWSER" "$url" &>/dev/null &
        disown
        opened=true
    fi

    if ! $opened && [[ -n "$BROWSER_FALLBACK" ]] && command -v "$BROWSER_FALLBACK" &>/dev/null; then
        notify "low" "Browser '$BROWSER' not found, using $BROWSER_FALLBACK"
        "$BROWSER_FALLBACK" "$url" &>/dev/null &
        disown
        opened=true
    fi

    if ! $opened; then
        notify "critical" "No browser available!" "Set BROWSER in the config section"
        echo "[settings-launcher] ERROR: no browser found (tried: $BROWSER, $BROWSER_FALLBACK)" >&2
        return 1
    fi
}

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#                   MAIN
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

main() {
    local active_launcher
    active_launcher=$(resolve_launcher)

    local menu_input
    menu_input=$(build_menu "$active_launcher")

    local selected
    selected=$(run_launcher "$active_launcher" "$menu_input")

    [[ -z "$selected" ]] && exit 0

    local cmd
    cmd=$(find_command "$selected")

    if [[ -z "$cmd" ]]; then
        notify "normal" "No command matched for selection" "$selected"
        echo "[settings-launcher] WARNING: no command matched for: '$selected'" >&2
        exit 1
    fi

    execute_entry "$cmd" "$active_launcher"
}

main "$@"
