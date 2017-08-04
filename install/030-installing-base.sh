#!/usr/bin/env bash

set -e

source ./ArchConfig/install/999-print-functions.sh
OUTPUT_FILE=$HOME/base-install.log

clear
print_message "Installing and configuring base system"
read -p "Are you installing on a laptop? (y/N): " LAPTOP_INSTALL

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

print_message "Complete"

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
print_message "Installing XORG Server"

print_multiline_message "Available targets:" "1. ATI 2. NVIDIA 3. INTEL 4. VIRTUALBOX"
read -p "Choose the target GPU driver (default = NONE): " GPU_TYPE

PACKAGES=( xorg-server xorg-xinit )
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


if [[ "$LAPTOP_INSTALL" == "y" ]]
then 
	# Custom LibInput touchpad driver settings 
	sudo cp $HOME/ArchConfig/config/30-touchpad.conf /etc/X11/xorg.conf.d/
fi

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
print_message "Installing i3 window manager with gaps"

packer -S --noconfirm --noedit "i3-gaps-git" >> $OUTPUT_FILE

# Additional required i3 software
PACKAGES=( i3blocks i3lock i3status )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Complete"

clear
print_message "Moving config files"

cp -r $HOME/ArchConfig/config/wallpapers $HOME/Pictures/
cp $HOME/ArchConfig/config/redshift.conf $HOME/.config/
cp $HOME/ArchConfig/config/compton.conf $HOME/.config/
cp $HOME/ArchConfig/config/i3blocks/config $HOME/.config/i3blocks/
sudo cp $HOME/ArchConfig/config/i3blocks/scripts/* /usr/lib/i3blocks/
cp $HOME/ArchConfig/config/i3/config $HOME/.config/i3/
cp $HOME/ArchConfig/config/i3/lock.sh $HOME/.config/i3/
cp $HOME/ArchConfig/config/.xinitrc $HOME/
cp $HOME/ArchConfig/config/.bash_profile $HOME/
cp $HOME/ArchConfig/config/.Xdefaults $HOME/

print_message "Complete"

clear
print_message "Installing additional software"

#software from 'normal' repositories+
packer -S --noconfirm --noedit "rslsync" >> $OUTPUT_FILE

PACKAGES=( bash-completion vim keepassxc )
PACKAGES+=( evince firefox youtube-dl )
PACKAGES+=( gimp compton ranger )
PACKAGES+=( gdisk cfdisk cmus )
PACKAGES+=( htop irssi mutt )
PACKAGES+=( feh rofi mpv )
PACKAGES+=( xorg-xset libnotify xautolock )
PACKAGES+=( redshift sane screenfetch scrot )
PACKAGES+=( simplescreenrecorder sysstat )
PACKAGES+=( transmission-cli rxvt-unicode )
PACKAGES+=( vnstat unclutter )
print_install PACKAGES[@] $OUTPUT_FILE

sudo systemctl enable vnstat
sudo systemctl start vnstat

if [[ "$LAPTOP_INSTALL" == "y" ]]
then 
	# Laptop power savings
    PACKAGES=( tlp tlp-rdw acpi_call smartmontools ethtool xorg-xbacklight acpi )
    print_install PACKAGES[@] $OUTPUT_FILE

	sudo systemctl enable tlp.service
	sudo systemctl enable tlp-sleep.service
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket
fi

#Utilities
PACKAGES=( udevil )
PACKAGES+=( unrar unzip )
PACKAGES+=( cups-pdf hplip )
print_install PACKAGES[@] $OUTPUT_FILE

until systemctl enable org.cups.cupsd.service
do 
    printf "\nPlease try again\n"
done
systemctl start org.cups.cupsd.service

#Sound
PACKAGES=( pulseaudio pulseaudio-alsa pamixer )
PACKAGES+=( alsa-utils alsa-firmware )
PACKAGES+=( gst-plugins-good gst-plugins-bad gst-plugins-ugly )
print_install PACKAGES[@] $OUTPUT_FILE

print_message "Complete"

clear
print_message "Rebooting, please wait..."
sleep 10

sudo reboot
