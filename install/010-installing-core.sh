#!/usr/bin/env bash

set -e

source ./999-print-functions.sh
boot_type=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
OUTPUT_FILE=core-install.log

clear
print_multiline_message "Beginning $boot_type installation" "output is captured in the file $OUTPUT_FILE"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core install started" >> $OUTPUT_FILE

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
    mkfs.vfat "${DEVICE_ID}1" >> $OUTPUT_FILE 

    mkswap "${DEVICE_ID}2" >> $OUTPUT_FILE
    swapon "${DEVICE_ID}2"

    mkfs.ext4 "${DEVICE_ID}3" >> $OUTPUT_FILE
    mkfs.ext4 "${DEVICE_ID}4" >> $OUTPUT_FILE
    mkfs.ext4 "${DEVICE_ID}5" >> $OUTPUT_FILE   
else
    mkswap "${DEVICE_ID}1" >> $OUTPUT_FILE
    swapon "${DEVICE_ID}1"

    mkfs.ext4 "${DEVICE_ID}2" >> $OUTPUT_FILE
    mkfs.ext4 "${DEVICE_ID}3" >> $OUTPUT_FILE
    mkfs.ext4 "${DEVICE_ID}4" >> $OUTPUT_FILE
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

pacstrap /mnt base base-devel >> $OUTPUT_FILE
genfstab -U /mnt >> /mnt/etc/fstab

print_message "Complete"

cp 020-configuring-core.sh /mnt
cp 999-print-functions.sh /mnt
mv $OUTPUT_FILE /mnt/home
arch-chroot /mnt ./020-configuring-core.sh
clear
print_message "Cleaning up"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Finished, rebooting system" >> /mnt/home/$OUTPUT_FILE
rm /mnt/020-configuring-core.sh
rm /mnt/999-print-functions.sh
print_message "Complete"

clear
print_message "Rebooting, please wait..."
sleep 10

reboot