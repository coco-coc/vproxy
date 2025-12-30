#!/bin/bash

# VProxy Wrapper Script - Automatically requests root privileges

APP_NAME="VProxy"
BINARY_PATH="$(dirname "$0")/vproxy"

# Function to show error dialog
show_error() {
    local message="$1"
    if command -v zenity >/dev/null 2>&1; then
        zenity --error --text="$message" --title="$APP_NAME" --width=400
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --error "$message" --title "$APP_NAME"
    else
        echo "ERROR: $message" >&2
    fi
}

# Function to show info dialog
show_info() {
    local message="$1"
    if command -v zenity >/dev/null 2>&1; then
        zenity --info --text="$message" --title="$APP_NAME" --width=400
    elif command -v kdialog >/dev/null 2>&1; then
        kdialog --msgbox "$message" --title "$APP_NAME"
    else
        echo "INFO: $message"
    fi
}

# Check if already running as root
if [ "$EUID" -eq 0 ]; then
    # Already root, run the application
    exec "$BINARY_PATH" "$@"
    exit $?
fi

# Not running as root, show info and try to elevate
show_info "$APP_NAME requires root privileges to manage network interfaces and system settings.\n\nPlease enter your password when prompted."

# Try different elevation methods in order of preference
if command -v pkexec >/dev/null 2>&1; then
    # PolicyKit (most user-friendly)
    exec pkexec "$BINARY_PATH" "$@"
elif command -v gksu >/dev/null 2>&1; then
    # GNOME su (deprecated but still sometimes available)
    exec gksu "$BINARY_PATH $*"
elif command -v kdesu >/dev/null 2>&1; then
    # KDE su
    exec kdesu "$BINARY_PATH $*"
elif command -v sudo >/dev/null 2>&1; then
    # Terminal sudo
    if [ -t 0 ] && [ -t 1 ]; then
        # Running in terminal
        echo "Please enter your password to run $APP_NAME with root privileges:"
        exec sudo "$BINARY_PATH" "$@"
    else
        # Not in terminal, try graphical sudo
        if command -v gksudo >/dev/null 2>&1; then
            exec gksudo "$BINARY_PATH $*"
        else
            show_error "Please run $APP_NAME from a terminal with:\nsudo vproxy"
            exit 1
        fi
    fi
else
    show_error "$APP_NAME requires root privileges but no elevation method is available.\n\nPlease run from terminal with:\nsu -c 'vproxy'"
    exit 1
fi