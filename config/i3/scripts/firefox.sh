#!/usr/bin/env bash

ps cax | grep firefox
if [ $? -eq 0 ]
then 
    i3-msg "[class=Firefox] focus"
else
    firefox
fi