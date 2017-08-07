#!/usr/bin/env bash

set -e

DEVICE_ID=$(sed '1q;d' options.conf)
ROOT_PASSWORD=$(sed '2q;d' options.conf)
NEW_USER_NAME=$(sed '3q;d' options.conf)
USER_PASSWORD=$(sed '4q;d' options.conf)
HOST_NAME=$(sed '5q;d' options.conf)
GPU_TYPE=$(sed '6q;d' options.conf)
INTEL_INSTALL=$(sed '7q;d' options.conf)
LAPTOP_INSTALL=$(sed '8q;d' options.conf)
PRINTER_INSTALL=$(sed '9q;d' options.conf)

source ./999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
OUTPUT_FILE=/home/core-install.log

clear
print_multiline_message "$(date +%d-%m-%Y---%H:%M:%S)" "Core configuration started" >> $OUTPUT_FILE
print_message "Core configuration"
PACKAGES=( git )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Adding user '$NEW_USER_NAME'"

useradd -m -g users -G wheel,storage,power -s /bin/bash $NEW_USER_NAME
sed -i "0,/# %wheel/s//%wheel/" /etc/sudoers

cd "/home/$NEW_USER_NAME"
git clone https://github.com/BardFusion/ArchConfig.git >> $OUTPUT_FILE
chown -R $NEW_USER_NAME:users "/home/$NEW_USER_NAME/ArchConfig" 
cp "/home/$NEW_USER_NAME/ArchConfig/install/.bash_profile" ./

printf "\n"
echo -e "$ROOT_PASSWORD\n$ROOT_PASSWORD" | passwd
echo -e "$USER_PASSWORD\n$USER_PASSWORD" | passwd $NEW_USER_NAME

print_message "Complete"
print_message "Configuring locales"

sed -i 's/#en_GB.UTF-8/en_GB.UTF-8/g' /etc/locale.gen
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
sed -i 's/#nl_NL.UTF-8/nl_NL.UTF-8/g' /etc/locale.gen

locale-gen >> $OUTPUT_FILE

echo LANG=en_US.UTF-8 > /etc/locale.conf
export LANG=en_US.UTF-8
echo -e "KEYMAP=us\nFONT=lat9w-16" > /etc/vconsole.conf

print_message "Complete"
print_message "Configuring time"

ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
hwclock --systohc --utc

print_message "Complete"
print_message "Configuring network"

echo $HOST_NAME > /etc/hostname

sed -i "s/localhost./tmp./g" /etc/hosts 
sed -i "s/localhost/localhost ${HOST_NAME}/g" /etc/hosts
sed -i "s/tmp./localhost./g" /etc/hosts

PACKAGES=( networkmanager wget )
print_install PACKAGES[@] $OUTPUT_FILE
printf "\n"
systemctl enable NetworkManager

print_message "Complete"
print_message "Installing XORG"

PACKAGES=( xorg-server xorg-xinit xorg-xrdb )
case $GPU_TYPE in
    1)
        PACKAGES+=( xf86-video-ati )
        ;;
    2)
        PACKAGES+=( xf86-video-nouveau )
        ;;
    3)
        PACKAGES+=( xf86-video-intel )  
        ;;
    4)
        PACKAGES+=( virtualbox-guest-utils ) 
        ;; 
esac
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Complete"

if [[ "$PRINTER_INSTALL" == "y" ]]
then
    print_message "Installing printer support"
    PACKAGES=( cups-pdf hplip sane )
    print_install PACKAGES[@] $OUTPUT_FILE
    until systemctl enable org.cups.cupsd.service
    do 
        printf "\nPlease try again\n"
    done
    systemctl start org.cups.cupsd.service   
    print_message "Complete"
fi

if [[ "$LAPTOP_INSTALL" == "y" ]]
then 
    print_message "Installing laptop specific packages"
	cp /home/$NEW_USER_NAME/ArchConfig/config/input/30-touchpad.conf /etc/X11/xorg.conf.d/
    PACKAGES=( xorg-xbacklight tlp tlp-rdw acpi_call acpi )
    print_install PACKAGES[@] $OUTPUT_FILE

    systemctl enable tlp.service
	systemctl enable tlp-sleep.service
	systemctl mask systemd-rfkill.service
	systemctl mask systemd-rfkill.socket
    print_message "Complete"
fi

if [[ ${#GPU_TYPE} != 0 ]]
then 
    mkdir -p /home/$NEW_USER_NAME/.config
    cp /home/$NEW_USER_NAME/ArchConfig/config/compton/compton.conf /home/$NEW_USER_NAME/.config/
    chown -R $NEW_USER_NAME:users /home/$NEW_USER_NAME/.config
fi

print_message "Installing bootloader"

if [[ "$BOOT_TYPE" == "BIOS" ]]
then
    print_message "Generating cpio init"

    mkinitcpio -p linux >> $OUTPUT_FILE

    print_message "Complete"
fi

if [[ "$BOOT_TYPE" == "UEFI" ]]
then
    bootctl install >> $OUTPUT_FILE
    if [[ "$INTEL_INSTALL" == "y" ]]
    then 
        PACKAGES=( intel-ucode )
        print_install PACKAGES[@] $OUTPUT_FILE
        echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /intel-ucode.img\ninitrd /initramfs-linux.img\noptions root=${DEVICE_ID}3 rw" > /boot/loader/entries/arch.conf
    else
        echo -e "title Arch Linux\nlinux /vmlinuz-linux\ninitrd /initramfs-linux.img\noptions root=${DEVICE_ID}3 rw" > /boot/loader/entries/arch.conf
    fi
    echo -e "default arch\ntimeout 4\neditor 0" > /boot/loader/loader.conf
else
    PACKAGES=( grub )
    print_install PACKAGES[@] $OUTPUT_FILE
    grub-install --target=i386-pc --recheck $DEVICE_ID >> $OUTPUT_FILE
    grub-mkconfig -o /boot/grub/grub.cfg
fi

print_message "Complete"
print_message "System installed succesfully" 
sleep 1