# XFCE4 window tools

Main script: `run-or-switch2.sh`

Usage: `APP_NAME="terminal" APP_COMMAND="xfce4-terminal" /absolute/path/to/run-or-switch2.sh`

APP_NAME - name of the application as it appears in the window list, shown in `wmctrl -lx` output
APP_COMMAND - command to launch the application (optional, defaults to lowercase app name)

The idea is to use Super+letter as a shortcut to launch the application, and then use Super+letter again to switch to the next window of the same application.

Shortcuts can be added manually to the `~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-keyboard-shortcuts.xml` file, or in the UI (search for "keyboard" keyword in the application menu), or by running the `init.sh` script.