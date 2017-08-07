#!/usr/bin/env bash

ps cax | grep thunderbird
if [ $? -eq 0 ]
then 
    i3-msg "[class=Thunderbird] focus"
else
    thunderbird
fi