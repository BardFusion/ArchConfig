#!/usr/bin/env bash

if ! pgrep -x "i3lock" > /dev/null
then
    # Take a screenshot
    scrot /tmp/screen_locked.png

    # Pixellate it 50x
    mogrify -scale 10% -scale 1000% /tmp/screen_locked.png

    # Lock the screen 
    i3lock -e -f -i /tmp/screen_locked.png
fi