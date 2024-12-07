#!/bin/bash

wmctrl -l | while read -r window_id window_num rest; do
    wmctrl -i -r "$window_id" -b add,hidden
done