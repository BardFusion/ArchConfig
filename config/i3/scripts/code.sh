#!/usr/bin/env bash

ps cax | grep code
if [ $? -eq 0 ]
then 
    i3-msg "[class=Code] focus"
else
    code
fi