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
print_multiline_message "Continueing $boot_type installation" "output is captured in the file '/home/install.log'"
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core configuration started" >> /home/install.log
sleep 4

clear
print_message "Configuring locales"

sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#nl_NL.UTF-8/nl_NL.UTF-8/g' /etc/locale.gen

locale-gen >> /home/install.log

echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "KEYMAP=us\nFONT=lat9w-16" > /etc/vconsole.conf

print_message "Complete"

clear
print_message "Configuring time"

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

print_message "Complete"

clear
print_message "Configuring network"

read -p "Enter the desired hostname: " HOST_NAME
echo $HOST_NAME > /etc/hostname

sed -i "s/localhost./tmp./g" /etc/hosts 
sed -i "s/localhost/localhost ${HOST_NAME}/g" /etc/hosts
sed -i "s/tmp./localhost./g" /etc/hosts

pacman -S --noconfirm networkmanager git wget >> /home/install.log
printf "\n"
systemctl enable NetworkManager

print_message "Complete"

clear
print_message "Installing bootloader"

pacman -S --noconfirm udevil >> /home/install.log

if [[ "$boot_type" == "BIOS" ]]
then
    print_message "Generating cpio init"

    mkinitcpio -p linux >> /home/install.log

    print_message "Complete"
fi

print_message "Available devices"

lsblk
printf "\n"

if [[ "$boot_type" == "UEFI" ]]
then
    read -p "Enter the root partition: " DEVICE_ID
    printf "\n"

    bootctl install >> /home/install.log
    pacman -S --noconfirm intel-ucode >> /home/install.log

    echo -e "default arch\ntimeout 4\neditor 0" > /boot/loader/loader.conf
    echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img\noptions root=${DEVICE_ID} rw" > /boot/loader/entries/arch.conf
else
    read -p "Enter the device for bootloader install: " DEVICE_ID
    printf "\n"

    pacman -S --noconfirm grub >> /home/install.log
    grub-install --target=i386-pc --recheck $DEVICE_ID >> /home/install.log
    grub-mkconfig -o /boot/grub/grub.cfg
fi

print_message "Complete"

clear
print_message "Enter root password"

passwd

print_message "Adding new user"

read -p "Username: " NEW_USER_NAME
useradd -m -g users -G wheel,storage,power -s /bin/bash $NEW_USER_NAME

passwd $NEW_USER_NAME
sed -i "0,/# %wheel/s//%wheel/" /etc/sudoers

cd "/home/$NEW_USER_NAME"
git clone https://github.com/BardFusion/ArchConfig.git

print_message "Complete"

clear
print_multiline_message "System installed succesfully" "exit to continue"