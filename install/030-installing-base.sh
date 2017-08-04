#!/usr/bin/env bash

set -e

source ./ArchConfig/install/999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
OUTPUT_FILE=$HOME/base-install.log

clear
print_message "Installing and configuring base system"

clear
print_message "Creating user folders"

[ -d $HOME/Documents ] || mkdir -p $HOME/Documents
[ -d $HOME/Downloads ] || mkdir -p $HOME/Downloads
[ -d $HOME/Music ] || mkdir -p $HOME/Music
[ -d $HOME/Pictures ] || mkdir -p $HOME/Pictures
[ -d $HOME/Videos ] || mkdir -p $HOME/Videos

until sudo mkdir -p  /usr/lib/i3blocks
do 
    printf "\nPlease try again\n"
done
mkdir -p $HOME/.config/i3
mkdir -p $HOME/.config/i3blocks
mkdir -p $HOME/.config/rslsync

clear
print_message "Updating mirrorlist"

PACKAGES=( reflector )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Ranking mirrors"
sudo reflector -l 100 -f 50 --sort rate --threads 4 --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

cat /etc/pacman.d/mirrorlist

sudo pacman -Syu >> $OUTPUT_FILE

print_message "Complete"

clear
print_message "Installing Packer AUR helper"

PACKAGES=( expac jshon )
print_install PACKAGES[@] $OUTPUT_FILE

[ -d /tmp/packer ] && rm -rf /tmp/packer
mkdir /tmp/packer
wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer >> $OUTPUT_FILE
mv PKGBUILD\?h\=packer /tmp/packer/PKGBUILD
cd /tmp/packer
makepkg -i /tmp/packer --noconfirm >> $OUTPUT_FILE
[ -d /tmp/packer ] && rm -rf /tmp/packer

print_message "Complete"

clear
print_message "Installing desktop environment"

print_message "i3 window manager with gaps [AUR]"

packer -S --noconfirm --noedit "i3-gaps-git" >> $OUTPUT_FILE

print_message "Additional software"
PACKAGES=( i3blocks i3lock i3status compton feh rofi libnotify xautolock redshift unclutter )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Complete"

clear

print_message "Installing desktop software"
print_message "Resilio sync [AUR]"

#software from 'normal' repositories+
packer -S --noconfirm --noedit "rslsync" >> $OUTPUT_FILE
cp $HOME/ArchConfig/config/rslsync.conf $HOME/.config/rslsync/
sed -i "s/\/var\/lib\/rslsync/\/home\/$USER\/.config\/rslsync/g" $HOME/.config/rslsync/rslsync.conf
sed -i "s/\/var\/run\/resilio\/resilio.pid/\/home\/$USER\/.config\/rslsync\/resilio.pid/g" $HOME/.config/rslsync/rslsync.conf

touch $HOME/.config/rslsync/resilio.pid
systemctl --user enable rslsync.service

print_message "System"
PACKAGES=( bash-completion htop smartmontools ethtool sysstat screenfetch udevil )
if [[ "$BOOT_TYPE" == "BIOS" ]]
then
    PACKAGES+=( cfdisk )
else
    PACKAGES+=( gdisk efibootmgr )
fi
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Printer"
PACKAGES+=( cups-pdf hplip sane )
print_install PACKAGES[@] $OUTPUT_FILE
until systemctl enable org.cups.cupsd.service
do 
    printf "\nPlease try again\n"
done
systemctl start org.cups.cupsd.service    

print_message "Audio"
PACKAGES=( gst-plugins-good gst-plugins-bad gst-plugins-ugly pulseaudio-alsa alsa-firmware pamixer alsa-utils )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Communication"
PACKAGES=( irssi mutt )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Workflow"
PACKAGES=( rxvt-unicode unrar unzip vim keepassxc libreoffice-fresh ranger openssh )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Media"
PACKAGES=( mpv cmus evince transmission-cli scrot gimp youtube-dl )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Web"
PACKAGES=( firefox )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Complete"

print_message "Moving config files"

sudo cp $HOME/ArchConfig/config/i3blocks/scripts/* /usr/lib/i3blocks/

cp -r $HOME/ArchConfig/config/wallpapers $HOME/Pictures/
cp $HOME/ArchConfig/config/redshift.conf $HOME/.config/
cp $HOME/ArchConfig/config/i3blocks/config $HOME/.config/i3blocks/
cp $HOME/ArchConfig/config/i3/config $HOME/.config/i3/
cp $HOME/ArchConfig/config/i3/lock.sh $HOME/.config/i3/
cp $HOME/ArchConfig/config/.xinitrc $HOME/
cp $HOME/ArchConfig/config/.bash_profile $HOME/
cp $HOME/ArchConfig/config/.Xdefaults $HOME/

print_message "Complete"


clear
print_message "Rebooting, please wait..."
sleep 10

sudo reboot
