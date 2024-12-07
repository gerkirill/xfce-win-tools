#!/bin/bash

# Configurable variables
APP_NAME="${APP_NAME:-'Vivaldi'}"
DEF_APP_COMMAND="${APP_NAME,,}"   # Command to launch the application (defaults to lowercase app name)
APP_COMMAND="${APP_COMMAND:-$DEF_APP_COMMAND}"
CYCLE_TIME=2                  # Time window for cycling (in seconds)
STATE_FILE="/tmp/${APP_NAME,,}_window_selector.state"

# Function to launch application
launch_app() {
    nohup "$APP_COMMAND" "$@" > /dev/null 2>&1 &
    # Wait a moment to allow the application to start
    sleep 0.5
    exit
}

# Current time
now=$(date +%s)

# Check if state file exists, if not create it
if [ ! -f "$STATE_FILE" ]; then
    echo "0 0" > "$STATE_FILE"
fi

# Read previous time and window index
read prev_time prev_index < "$STATE_FILE"

# Get all application window IDs
windows=($(wmctrl -lx | grep "$APP_NAME" | awk '{print $1}'))

# Check if no application windows are open
if [ ${#windows[@]} -eq 0 ]; then
    launch_app "$@"
fi

# If called within configured time, cycle to next window
if [ $((now - prev_time)) -le "$CYCLE_TIME" ]; then
    # Increment index, wrap around if needed
    next_index=$(( (prev_index + 1) % ${#windows[@]} ))
else
    # If more than configured time has passed, start from the first window
    next_index=0
fi

# Activate the selected window
wmctrl -i -a "${windows[$next_index]}"

# Update state file with current time and window index
echo "$now $next_index" > "$STATE_FILE"