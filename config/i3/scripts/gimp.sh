#!/usr/bin/env bash

ps cax | grep gimp
if [ $? -eq 0 ]
then 
    i3-msg "[class=Gimp] focus"
else
    gimp
fi