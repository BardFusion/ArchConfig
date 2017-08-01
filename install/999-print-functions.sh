#!/usr/bin/env bash

set -e

# Print a message to the terminal padded with "=" characters
# the resulting width will be 1.5 times the message length
function print_message 
{   
    local message=$1
    local message_size=${#message}
    local message_size=$(expr $message_size / 2)
    local print_width=$(expr ${#message} \* 3)
    local print_width=$(expr $print_width / 2)
    local padding_horizontal="$(printf "%0.s=" $(seq 1 $message_size))"
    local padding_vertical="$(printf "%0.s=" $(seq 1 $print_width))$padding_horizontal="

    # Top row 
    printf "\n$padding_vertical\n"
    
    # Message
    printf "$padding_horizontal $message $padding_horizontal\n"

    # Bottom row
    printf "$padding_vertical\n\n"

    sleep 0.75
}

# Print a combined message of two lines to the terminal padded with "=" characters
# the resulting width will be 1.5 times the longest line length
function print_multiline_message 
{   
    local message_1=$1
    local message_2=$2
    local message_1_size=${#message_1}
    local message_2_size=${#message_2}

    if [[ "$message_1_size" > "$message_2_size" ]]
    then
        print_width=$(expr $message_1_size \* 3)
        width_difference=$(expr $message_1_size - $message_2_size)
        message_2="$message_2$(printf "%0.s " $(seq 1 $width_difference))"
    else
        print_width=$(expr $message_2_size \* 3)
        width_difference=$(expr $message_2_size - $message_1_size)
        message_1="$message_1$(printf "%0.s " $(seq 1 $width_difference))"
    fi

    local message_size=$(expr $print_width / 3 - 1)
    local message_size=$(expr $message_size / 2)
    local print_width=$(expr $print_width / 2)
    local padding_horizontal="$(printf "%0.s=" $(seq 1 $message_size))"
    local padding_vertical="$(printf "%0.s=" $(seq 1 $print_width))$padding_horizontal="

    # Top row 
    printf "\n$padding_vertical\n"
    
    # Message 1
    printf "$padding_horizontal $message_1 $padding_horizontal\n"

    # Message 2
    printf "$padding_horizontal $message_2 $padding_horizontal\n"

    # Bottom row
    printf "$padding_vertical\n\n"

    sleep 0.75
}