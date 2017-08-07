#!/usr/bin/env bash

ps cax | grep terminator
if [ $? -eq 0 ]
then 
    i3-msg "[class=Terminator] focus"
else
    terminator
fi