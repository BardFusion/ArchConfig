#!/usr/bin/env bash

ps cax | grep keepassxc
if [ $? -eq 0 ]
then 
    i3-msg "[class=keepassxc] focus"
else
    keepassxc
fi