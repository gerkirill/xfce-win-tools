#!/bin/bash

APP_NAME="${APP_NAME:-'Vivaldi'}"
DEF_APP_COMMAND="${APP_NAME,,}"   # Command to launch the application (defaults to lowercase app name)
APP_COMMAND="${APP_COMMAND:-$DEF_APP_COMMAND}"

app_name="${APP_NAME}"

workspace_number=`wmctrl -d | grep '\*' | cut -d' ' -f 1`
win_list=`wmctrl -lx | grep $app_name | grep " $workspace_number " | awk '{print $1}'`

# Get the id of the active window (i.e., window which has the focus)
active_win_id=`xprop -root | grep '^_NET_ACTIVE_W' | awk -F'# 0x' '{print $2}' | awk -F', ' '{print $1}'`
if [ "$active_win_id" == "0" ]; then
    active_win_id=""
fi

# Function to minimize windows on the same monitor
minimize_other_windows() {
    local target_window_id="$1"
    
    # Get the Y position of the target window
    local target_y=$(xdotool getwindowgeometry "$target_window_id" grep "Position:" | awk -F'[:,]' '{print $3}' | grep -oE '^[0-9]+')
    
    # Determine monitor based on Y position
    local monitor_threshold=1430
    local target_monitor=$([[ "$target_y" -lt "$monitor_threshold" ]] && echo "top" || echo "bottom")
    
    # Get list of all windows
    wmctrl -l | while read -r window_id desktop_num rest; do
        # Skip the target window itself
        if [[ "$window_id" != "$target_window_id" ]]; then
            # Get window Y position
            local window_y=$(xdotool getwindowgeometry "$window_id" grep "Position:" | awk -F'[:,]' '{print $3}' | grep -oE '^[0-9]+')
            
            # Check if window is on the same monitor
            local window_monitor=$([[ "$window_y" -lt "$monitor_threshold" ]] && echo "top" || echo "bottom")
            
            if [[ "$window_monitor" == "$target_monitor" ]]; then
                wmctrl -i -r "$window_id" -b add,hidden
            fi
        fi
    done
}

# If the window currently focused matches the first argument, seek the id of the next window in win_list which matches it
if [[ "$win_list" == *"$active_win_id"* ]]; then

    # Get next window to focus on 
    # (sed removes the focused window and the previous windows from the list)
    switch_to=`echo $win_list | sed s/.*$active_win_id// | awk '{print $1}'`

    # If the focused window is the last in the list, take the first one
    if [ "$switch_to" == "" ];then
        switch_to=`echo $win_list | awk '{print $1}'`
    fi

# If the currently focused window does not match the first argument
else

    # Get the list of all the windows which do
    win_list=$(wmctrl -lx | grep $app_name | awk '{print $1}')

    IDs=$(xprop -root|grep "^_NET_CLIENT_LIST_STACKING" | tr "," " ")
    IDs=(${IDs##*#})

   # For each window in focus order
    for (( idx=${#IDs[@]}-1 ; idx>=0 ; idx-- )) ; do
        for i in $win_list; do

           # If the window matches the first argument, focus on it
            if [ $((i)) = $((IDs[idx])) ]; then
                wmctrl -ia $i
                # Minimize other windows on the same monitor
                minimize_other_windows $i
                exit 0
            fi
        done
    done
fi

# If a window to focus on has been found, focus on it
if [[ -n "${switch_to}" ]]
then
    # Activate the window
    wmctrl -ia "$switch_to"
    # Minimize other windows on the same monitor
    minimize_other_windows "$switch_to"

# If there is no window which matches the first argument
else

    # If there is a second argument which specifies a command to run, run it
    if [[ -n "${APP_COMMAND}" ]]
    then
        nohup "$APP_COMMAND" "$@" > /dev/null 2>&1 &
        # Wait a moment to allow the application to start
        sleep 0.5
        exit
    fi
fi

exit 0