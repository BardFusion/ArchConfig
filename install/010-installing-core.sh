#!/usr/bin/env bash

set -e

source ./999-print-functions.sh
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
print_message "Rebooting, please wait..."
sleep 10

reboot