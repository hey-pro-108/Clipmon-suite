#!/usr/bin/env bash

get_platform() {
    if [ -d "/data/data/com.termux" ] 2>/dev/null; then
        echo "TERMUX"
    elif [ "$(uname)" = "Darwin" ]; then
        echo "MACOS"
    elif grep -qi microsoft /proc/version 2>/dev/null; then
        echo "WSL"
    elif [ -f "/etc/os-release" ]; then
        echo "LINUX"
    else
        echo "UNIX"
    fi
}

get_clipboard() {
    local platform=$(get_platform)
    
    case $platform in
        TERMUX)
            if command -v termux-clipboard-get >/dev/null 2>&1; then
                termux-clipboard-get 2>/dev/null
            fi
            ;;
        MACOS)
            if command -v pbpaste >/dev/null 2>&1; then
                pbpaste 2>/dev/null
            fi
            ;;
        LINUX|WSL|UNIX)
            if command -v xclip >/dev/null 2>&1; then
                xclip -selection clipboard -o 2>/dev/null
            elif command -v xsel >/dev/null 2>&1; then
                xsel --clipboard --output 2>/dev/null
            fi
            ;;
    esac
}

set_clipboard() {
    local content="$1"
    local platform=$(get_platform)
    
    case $platform in
        TERMUX)
            if command -v termux-clipboard-set >/dev/null 2>&1; then
                termux-clipboard-set "$content" 2>/dev/null
            fi
            ;;
        MACOS)
            if command -v pbcopy >/dev/null 2>&1; then
                echo "$content" | pbcopy 2>/dev/null
            fi
            ;;
        LINUX|WSL|UNIX)
            if command -v xclip >/dev/null 2>&1; then
                echo "$content" | xclip -selection clipboard 2>/dev/null
            elif command -v xsel >/dev/null 2>&1; then
                echo "$content" | xsel --clipboard --input 2>/dev/null
            fi
            ;;
    esac
}

get_source() {
    local platform=$(get_platform)
    
    case $platform in
        TERMUX)
            echo "termux"
            ;;
        MACOS)
            if command -v osascript >/dev/null 2>&1; then
                osascript -e 'tell application "System Events" to get name of first application process whose frontmost is true' 2>/dev/null | tr -d '\n'
            else
                echo "mac_app"
            fi
            ;;
        LINUX|WSL)
            if command -v xdotool >/dev/null 2>&1; then
                local pid=$(xdotool getwindowpid $(xdotool getactivewindow) 2>/dev/null)
                if [ -n "$pid" ]; then
                    ps -p "$pid" -o comm= 2>/dev/null | head -1 | xargs
                else
                    echo "linux_app"
                fi
            else
                echo "linux_app"
            fi
            ;;
        *) echo "unknown" ;;
    esac
}

calculate_hash() {
    echo "$1" | sha256sum | cut -d' ' -f1
}

send_notification() {
    local title="$1"
    local message="$2"
    local platform=$(get_platform)
    
    if [ "$ENABLE_NOTIFY" != "true" ]; then
        return
    fi
    
    case $platform in
        TERMUX)
            if command -v termux-notification >/dev/null 2>&1; then
                termux-notification --title "$title" --content "$message" --priority high 2>/dev/null
            fi
            ;;
        LINUX|WSL)
            if command -v notify-send >/dev/null 2>&1; then
                notify-send -u critical "$title" "$message" 2>/dev/null
            fi
            ;;
        MACOS)
            if command -v osascript >/dev/null 2>&1; then
                osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null
            fi
            ;;
    esac
}

log_message() {
    local level=$1
    local message=$2
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" >> "$LOG_DIR/clipmon.log"
}
