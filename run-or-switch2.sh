# #!/bin/bash
# if [ $# -lt 1 ] ; then
#   echo "Usage : $0 <window name> [<command to run if there is no window with that name>]"
#   exit 1
# fi

APP_NAME="${APP_NAME:-'Vivaldi'}"
DEF_APP_COMMAND="${APP_NAME,,}"   # Command to launch the application (defaults to lowercase app name)
APP_COMMAND="${APP_COMMAND:-$DEF_APP_COMMAND}"



# app_name=$1
app_name="${APP_NAME}"

workspace_number=`wmctrl -d | grep '\*' | cut -d' ' -f 1`
win_list=`wmctrl -lx | grep $app_name | grep " $workspace_number " | awk '{print $1}'`

# Get the id of the active window (i.e., window which has the focus)
active_win_id=`xprop -root | grep '^_NET_ACTIVE_W' | awk -F'# 0x' '{print $2}' | awk -F', ' '{print $1}'`
if [ "$active_win_id" == "0" ]; then
    active_win_id=""
fi

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
                exit 0
            fi
        done
    done
fi

# If a window to focus on has been found, focus on it
if [[ -n "${switch_to}" ]]
then
    (wmctrl -ia "$switch_to") &

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