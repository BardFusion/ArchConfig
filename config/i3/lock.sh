#!/usr/bin/env bash

# Take a screenshot
scrot /tmp/screen_locked.png

# Pixellate it 50x
mogrify -scale 10% -scale 1000% /tmp/screen_locked.png

# Lock the screen, displaying the pixellated image
i3lock -e -i /tmp/screen_locked.png