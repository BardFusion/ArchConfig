#!/usr/bin/env bash

if [ $(ps aux | grep -c terminator) -eq 1 ]; then
    terminator
else
    i3-msg "[class=Terminator] focus"
fi