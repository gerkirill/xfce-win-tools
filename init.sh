#!/bin/bash

BIN_DIR="$HOME/bin"
# Function to set a keyboard shortcut
set_shortcut() {
    local shortcut="$1"
    local command="$2"

    # Clear any existing binding for the shortcut
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$shortcut" -r
    # Set the new command for the shortcut
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/$shortcut" -n -t string -s "$command"
}

# Example usage of the function
set_shortcut "<Super>b" "$BIN_DIR/win-tg-max.sh"
set_shortcut "<Super>c" "$BIN_DIR/cde.sh"
set_shortcut "<Super>d" "$BIN_DIR/hideall.sh"
set_shortcut "<Super>e" "$BIN_DIR/tg.sh"
set_shortcut "<Super>f" "$BIN_DIR/fm.sh"
set_shortcut "<Super>g" "$BIN_DIR/sg.sh"
set_shortcut "<Super>o" "$BIN_DIR/obsid.sh"
set_shortcut "<Super>q" "$BIN_DIR/win-min.sh"
set_shortcut "<Super>t" "$BIN_DIR/term.sh"
set_shortcut "<Super>v" "$BIN_DIR/viva.sh"
set_shortcut "<Super>w" "$BIN_DIR/chr.sh"
