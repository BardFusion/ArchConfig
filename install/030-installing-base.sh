#!/usr/bin/env bash

set -e

source ./ArchConfig/install/999-print-functions.sh

clear
print_message "Installing and configuring base system"
read -p "Are you installing on a laptop? (y/N): " LAPTOP_INSTALL

clear
print_message "Creating all folders"

[ -d $HOME/Documents ] || mkdir -p $HOME/Documents
[ -d $HOME/Downloads ] || mkdir -p $HOME/Downloads
[ -d $HOME/Music ] || mkdir -p $HOME/Music
[ -d $HOME/Pictures ] || mkdir -p $HOME/Pictures
[ -d $HOME/Videos ] || mkdir -p $HOME/Videos

print_message "Complete"

clear
print_message "Updating mirrorlist"

sudo pacman -S --noconfirm --needed reflector

sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

cat /etc/pacman.d/mirrorlist

sudo pacman -Syu

print_message "Complete"

clear
print_message "Installing XORG Server"

print_multiline_message "Available targets:" "1. ATI\t2. NVIDIA\t3. INTEL\t4. VIRTUALBOX\t5. NONE"
read -p "Choose the target GPU driver: " GPU_TYPE

case $GPU_TYPE in
    1)
        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit
        sudo pacman -S --noconfirm --needed xf86-video-ati 
        ;;
    2)
        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit
        sudo pacman -S --noconfirm --needed xf86-video-nouveau
        ;;
    3)
        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit
        sudo pacman -S --noconfirm --needed xf86-video-intel
        ;;
    4)
        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit 
        sudo pacman -S virtualbox-guest-utils
        ;; 
	5)
		sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit
		;;
esac

if [[ "$LAPTOP_INSTALL" == "y" ]]
then 
	# Custom LibInput touchpad driver settings 
	sudo cp $HOME/ArchConfig/config/30-touchpad.conf /etc/X11/xorg.conf.d/
fi

print_message "Complete"

clear
print_message "Installing Packer AUR helper"

sudo pacman -S --noconfirm --needed curl expac grep jshon sed git

[ -d /tmp/packer ] && rm -rf /tmp/packer
mkdir /tmp/packer
wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer
mv PKGBUILD\?h\=packer /tmp/packer/PKGBUILD
cd /tmp/packer
makepkg -i /tmp/packer --noconfirm
[ -d /tmp/packer ] && rm -rf /tmp/packer

print_message "Complete"

clear
print_message "Installing i3 window manager with gaps"

packer -S --noconfirm --noedit "i3-gaps-git"

# Additional required i3 software
sudo pacman -S --noconfirm --needed i3blocks i3lock i3status

print_message "Complete"

clear
print_message "Moving config files"

sudo mkdir -p  /usr/lib/i3blocks
sudo cp $HOME/ArchConfig/config/i3blocks/scripts/* /usr/lib/i3blocks/

mkdir -p $HOME/.config/i3
mkdir -p $HOME/.config/i3blocks
cp $HOME/ArchConfig/config/i3blocks/config $HOME/.config/i3blocks/
cp $HOME/ArchConfig/config/i3/config $HOME/.config/i3/
cp $HOME/ArchConfig/config/i3/lock.sh $HOME/.config/i3/
chmod +x $HOME/.config/i3/lock.sh
cp -r $HOME/ArchConfig/config/wallpapers $HOME/Pictures/

cp $HOME/ArchConfig/config/.xinitrc $HOME/
cp $HOME/ArchConfig/config/.bash_profile $HOME/
cp $HOME/ArchConfig/config/.Xdefaults $HOME/

print_message "Complete"

clear
print_message "Installing additional software"

#software from 'normal' repositories+
sudo pacman -S --noconfirm --needed curl bash-completion vim keepassxc
sudo pacman -S --noconfirm --needed evince firefox youtube-dl
sudo pacman -S --noconfirm --needed gimp git gksu glances compton
sudo pacman -S --noconfirm --needed gnome-font-viewer python-psutil
sudo pacman -S --noconfirm --needed gparted cmus mpc python-netifaces
sudo pacman -S --noconfirm --needed hardinfo hddtemp htop irssi python-requests
sudo pacman -S --noconfirm --needed lm_sensors lsb-release mpv
sudo pacman -S --noconfirm --needed numlockx xorg-xset libnotify xautolock
sudo pacman -S --noconfirm --needed redshift ristretto sane screenfetch scrot 
sudo pacman -S --noconfirm --needed simple-scan simplescreenrecorder sysstat 
sudo pacman -S --noconfirm --needed transmission-cli transmission-gtk rxvt-unicode
sudo pacman -S --noconfirm --needed vnstat wget unclutter network-manager-applet

sudo systemctl enable vnstat
sudo systemctl start vnstat

if [[ "$LAPTOP_INSTALL" == "y" ]]
then 
	# Laptop power savings
	sudo pacman -S --noconfirm --needed tlp tlp-rdw acpi_call smartmontools ethtool xorg-xbacklight acpi

	sudo systemctl enable tlp.service
	sudo systemctl enable tlp-sleep.service
	sudo systemctl mask systemd-rfkill.service
	sudo systemctl mask systemd-rfkill.socket
fi

#Utilities
sudo pacman -S --noconfirm --needed feh
sudo pacman -S --noconfirm --needed arandr
sudo pacman -S --noconfirm --needed xorg-xrandr
sudo pacman -S --noconfirm --needed gvfs
sudo pacman -S --noconfirm --needed volumeicon
sudo pacman -S --noconfirm --needed rofi 
sudo pacman -S --noconfirm --needed udevil 

# installation of zippers and unzippers
sudo pacman -S --noconfirm --needed unrar zip unzip sharutils

sudo pacman -S --noconfirm --needed cups cups-pdf ghostscript gsfonts libcups hplip system-config-printer 

systemctl enable org.cups.cupsd.service
systemctl start org.cups.cupsd.service

#Sound
sudo pacman -S --noconfirm --needed pulseaudio pulseaudio-alsa pavucontrol
sudo pacman -S --noconfirm --needed alsa-utils alsa-plugins alsa-lib alsa-firmware
sudo pacman -S --noconfirm --needed gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly gstreamer

#Fonts
sudo pacman -S --noconfirm --needed noto-fonts 
sudo pacman -S --noconfirm --needed ttf-ubuntu-font-family
sudo pacman -S --noconfirm --needed ttf-droid --noconfirm
sudo pacman -S --noconfirm --needed ttf-inconsolata

print_message "Complete"

clear
print_message "Rebooting, please wait..."
sleep 10

sudo reboot