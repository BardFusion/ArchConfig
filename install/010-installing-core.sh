#!/usr/bin/env bash

set -e

source ./999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
OUTPUT_FILE=core-install.log

clear
print_multiline_message "Beginning $BOOT_TYPE installation" "output is captured in the file $OUTPUT_FILE"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core install started" >> $OUTPUT_FILE

loadkeys us

read -p "Hostname: " HOST_NAME
read -p "Username: " NEW_USER_NAME
printf "User password: "
read -s USER_PASSWORD
printf "\n"
printf "Root password: "
read -s ROOT_PASSWORD
printf "\n"
read -p "Are you installing on a laptop? (y/N): " LAPTOP_INSTALL
read -p "Are you using an intel processor? (y/N): " INTEL_INSTALL
read -p "Install printer support? (y/N): " PRINTER_INSTALL

print_multiline_message "Available targets:" "1. ATI 2. NVIDIA 3. INTEL 4. VIRTUALBOX"
read -p "Choose the target GPU driver (default = NONE): " GPU_TYPE

print_message "Available devices"
lsblk
printf "\n"
read -p "Enter the device to use: " DEVICE_ID

echo $DEVICE_ID >> options.conf
echo $ROOT_PASSWORD >> options.conf
echo $NEW_USER_NAME >> options.conf 
echo $USER_PASSWORD >> options.conf
echo $HOST_NAME >> options.conf
echo $GPU_TYPE >> options.conf
echo $INTEL_INSTALL >> options.conf 
echo $LAPTOP_INSTALL >> options.conf
echo $PRINTER_INSTALL >> options.conf

clear
print_message "Partitioning disk"

if [[ "$BOOT_TYPE" == "UEFI" ]]
then
    sgdisk -og $DEVICE_ID >> $OUTPUT_FILE
    sgdisk -n 1:2048:1050623 -c 1:"EFI System Partition" -t 1:ef00 $DEVICE_ID >> $OUTPUT_FILE
    sgdisk -n 2:1050624:9439231 -c 2:"Swap space" -t 2:8200 $DEVICE_ID >> $OUTPUT_FILE
    sgdisk -n 3:9439232:51382271 -c 3:"Linux root" -t 3:8300 $DEVICE_ID >> $OUTPUT_FILE
    sgdisk -n 4:51382272:72353791 -c 4:"Linux var" -t 4:8300 $DEVICE_ID >> $OUTPUT_FILE
    END_SECTOR=`sgdisk -E $DEVICE_ID`
    sgdisk -n 5:72353792:$END_SECTOR -c 5:"Linux home" -t 5:8300 $DEVICE_ID >> $OUTPUT_FILE
    sgdisk -p $DEVICE_ID >> $OUTPUT_FILE
else
    cfdisk $DEVICE_ID
fi

print_message "Complete"
print_message "Formatting file systems"

if [[ "$BOOT_TYPE" == "UEFI" ]]
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

print_message "Complete"
print_message "Mounting file systems"

if [[ "$BOOT_TYPE" == "UEFI" ]]
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
print_message "Installing base system"

pacstrap /mnt base base-devel >> $OUTPUT_FILE
genfstab -U /mnt >> /mnt/etc/fstab

print_message "Complete"

cp 020-configuring-core.sh /mnt
cp 999-print-functions.sh /mnt
mv options.conf /mnt
mv $OUTPUT_FILE /mnt/home
arch-chroot /mnt ./020-configuring-core.sh

print_message "Cleaning up"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Finished, rebooting system" >> /mnt/home/$OUTPUT_FILE
rm /mnt/020-configuring-core.sh
rm /mnt/999-print-functions.sh
echo " " > /mnt/options.conf
rm /mnt/options.conf
print_message "Complete"

clear
print_message "Rebooting, please wait..."
sleep 10

reboot