#!/usr/bin/env bash

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

set -e
boot_type=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)

clear
print_multiline_message "Beginning $boot_type installation" "output is captured in the file 'install.log'"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core install started" >> install.log

loadkeys us

print_message "Available devices"
lsblk
printf "\n"
read -p "Enter the device to use: " DEVICE_ID

if [[ "$boot_type" == "UEFI" ]]
then
    gdisk $DEVICE_ID
else
    cfdisk $DEVICE_ID
fi

clear
print_message "Formatting file systems"

if [[ "$boot_type" == "UEFI" ]]
then
    mkfs.vfat "${DEVICE_ID}1" >> install.log 

    mkswap "${DEVICE_ID}2" >> install.log
    swapon "${DEVICE_ID}2"

    mkfs.ext4 "${DEVICE_ID}3" >> install.log
    mkfs.ext4 "${DEVICE_ID}4" >> install.log
    mkfs.ext4 "${DEVICE_ID}5" >> install.log   
else
    mkswap "${DEVICE_ID}1" >> install.log
    swapon "${DEVICE_ID}1"

    mkfs.ext4 "${DEVICE_ID}2" >> install.log
    mkfs.ext4 "${DEVICE_ID}3" >> install.log
    mkfs.ext4 "${DEVICE_ID}4" >> install.log
fi

print_message "Mounting file systems"

if [[ "$boot_type" == "UEFI" ]]
then
    mount "${DEVICE_ID}3" /mnt
    mkdir /mnt/boot
    mount "${DEVICE_ID}1" /mnt/boot
    mkdir /mnt/var
    mount "${DEVICE_ID}4" /mnt/var
    mkdir /mnt/home
    mount "${DEVICE_ID}5" /mnt/home    
else
    mount "${DEVICE_ID}2" /mnt
    mkdir /mnt/var
    mount "${DEVICE_ID}3" /mnt/var
    mkdir /mnt/home
    mount "${DEVICE_ID}4" /mnt/home
fi

print_message "Complete"

clear
print_message "Installing base system"

pacstrap /mnt base base-devel >> install.log
genfstab -U /mnt >> /mnt/etc/fstab

print_message "Complete"

mv 020-configuring-core.sh /mnt
mv install.log /mnt/home
arch-chroot /mnt ./020-configuring-core.sh
clear
print_message "Cleaning up"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Finished, rebooting system" >> /mnt/home/install.log
rm /mnt/020-configuring-core.sh
print_message "Complete"

clear
print_message "Rebooting"
sleep 1

reboot