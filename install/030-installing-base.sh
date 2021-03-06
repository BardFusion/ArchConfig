#!/usr/bin/env bash

set -e

source ./ArchConfig/install/999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)
OUTPUT_FILE=$HOME/base-install.log

clear
print_message "Installing and configuring base system"
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
mkdir -p $HOME/.config/terminator
mkdir -p $HOME/.irssi/scripts/autorun

print_message "Complete"
print_message "Updating mirrorlist"

PACKAGES=( reflector )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Ranking mirrors"
sudo reflector -l 100 -f 50 --sort rate --threads 4 --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

cat /etc/pacman.d/mirrorlist

sudo pacman -Syu >> $OUTPUT_FILE

print_message "Complete"
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
print_message "Installing vs-code [AUR]"

packer -S --noconfirm --noedit "visual-studio-code" >> $OUTPUT_FILE

print_message "Complete"
print_message "Installing font-awesome [AUR]"

packer -S --noconfirm --noedit "ttf-font-awesome" >> $OUTPUT_FILE

print_message "Complete"
print_message "Installing Resilio sync [AUR]"

packer -S --noconfirm --noedit "rslsync" >> $OUTPUT_FILE
cp $HOME/ArchConfig/config/resilio/rslsync.conf $HOME/.config/rslsync/
sed -i "s/\/var\/lib\/rslsync/\/home\/$USER\/.config\/rslsync/g" $HOME/.config/rslsync/rslsync.conf
sed -i "s/\/var\/run\/resilio\/resilio.pid/\/home\/$USER\/.config\/rslsync\/resilio.pid/g" $HOME/.config/rslsync/rslsync.conf

touch $HOME/.config/rslsync/resilio.pid
systemctl --user enable rslsync.service

print_message "Complete"
print_message "Installing remaining software"
print_message "System"
PACKAGES=( bash-completion htop smartmontools ethtool sysstat screenfetch udevil xclip arandr )
if [[ "$BOOT_TYPE" == "BIOS" ]]
then
    PACKAGES+=( cfdisk )
else
    PACKAGES+=( gdisk efibootmgr )
fi
print_install PACKAGES[@] $OUTPUT_FILE 

print_message "Desktop"
PACKAGES=( i3 feh rofi libnotify redshift xautolock )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Audio"
PACKAGES=( gst-plugins-good gst-plugins-bad gst-plugins-ugly pulseaudio-alsa alsa-firmware pamixer alsa-utils )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Communication"
PACKAGES=( irssi thunderbird )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Workflow"
PACKAGES=( terminator unrar unzip vim keepassxc libreoffice-fresh ranger openssh )
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
cp $HOME/ArchConfig/config/redshift/redshift.conf $HOME/.config/
cp $HOME/ArchConfig/config/terminator/config $HOME/.config/terminator/
cp $HOME/ArchConfig/config/i3blocks/config $HOME/.config/i3blocks/
cp $HOME/ArchConfig/config/i3/config $HOME/.config/i3/
cp $HOME/ArchConfig/config/i3/scripts/* $HOME/.config/i3/
cp $HOME/ArchConfig/config/xorg/.xinitrc $HOME/
cp $HOME/ArchConfig/config/xorg/.Xresources $HOME/
cp $HOME/ArchConfig/config/bash/.bash_profile $HOME/

cp $HOME/ArchConfig/config/irssi/nickcolor.pl $HOME/.irssi/scripts/
ln -s $HOME/.irssi/scripts/nickcolor.pl $HOME/.irssi/scripts/autorun/

print_message "Complete"


clear
print_message "Rebooting, please wait..."
sleep 10

sudo reboot
