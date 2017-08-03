#!/usr/bin/env bash

set -e

source ./999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
PACKAGES=()
OUTPUT_FILE=/home/install.log

clear
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core configuration started" >> /home/install.log
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

PACKAGES=( networkmanager git wget )
print_install $PACKAGES $OUTPUT_FILE
printf "\n"
systemctl enable NetworkManager

print_message "Complete"

clear
print_message "Installing bootloader"

if [[ "$BOOT_TYPE" == "BIOS" ]]
then
    print_message "Generating cpio init"

    mkinitcpio -p linux >> /home/install.log

    print_message "Complete"
fi

print_message "Available devices"

lsblk
printf "\n"

if [[ "$BOOT_TYPE" == "UEFI" ]]
then
    read -p "Enter the root partition: " DEVICE_ID
    read -p "Are you using an intel processor? (y/N): " INTEL_INSTALL
    printf "\n"

    bootctl install >> /home/install.log
    if [[ "$INTEL_INSTALL" == "y" ]]
    then 
        PACKAGES=( intel-ucode )
        print_install $PACKAGES $OUTPUT_FILE
        echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img\noptions root=${DEVICE_ID} rw" > /boot/loader/entries/arch.conf
    else
        echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=${DEVICE_ID} rw" > /boot/loader/entries/arch.conf
    fi
    echo -e "default arch\ntimeout 4\neditor 0" > /boot/loader/loader.conf
else
    read -p "Enter the device for bootloader install: " DEVICE_ID
    printf "\n"

    PACKAGES=( grub )
    print_install $PACKAGES $OUTPUT_FILE
    grub-install --target=i386-pc --recheck $DEVICE_ID >> /home/install.log
    grub-mkconfig -o /boot/grub/grub.cfg
fi

print_message "Complete"

clear
print_message "Enter root password"

until passwd
do 
    printf "\nPlease try again\n"
done

print_message "Adding new user"

read -p "Username: " NEW_USER_NAME
useradd -m -g users -G wheel,storage,power -s /bin/bash $NEW_USER_NAME

until passwd $NEW_USER_NAME
do 
    printf "\nPlease try again\n"
done
sed -i "0,/# %wheel/s//%wheel/" /etc/sudoers

printf "\n"

cd "/home/$NEW_USER_NAME"
git clone https://github.com/BardFusion/ArchConfig.git >> /home/install.log
chmod +x "/home/$NEW_USER_NAME/ArchConfig/install/030-installing-base.sh"
chown -R $NEW_USER_NAME:users "/home/$NEW_USER_NAME/ArchConfig" 
cp "/home/$NEW_USER_NAME/ArchConfig/install/.bash_profile" ./

print_message "Complete"

clear
print_multiline_message "System installed succesfully" "exit to continue"