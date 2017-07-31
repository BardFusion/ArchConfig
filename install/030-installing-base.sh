#!/usr/bin/env bash

set -e

echo "Creating all folders"

[ -d $HOME"/Documents" ] || mkdir -p $HOME"/Documents"
[ -d $HOME"/Downloads" ] || mkdir -p $HOME"/Downloads"
[ -d $HOME"/Music" ] || mkdir -p $HOME"/Music"
[ -d $HOME"/Pictures" ] || mkdir -p $HOME"/Pictures"
[ -d $HOME"/Videos" ] || mkdir -p $HOME"/Videos"

echo "################################################################"
echo "#########       personal folders copied         ################"
echo "################################################################"

sudo pacman -S --noconfirm --needed reflector

# finding the fastest archlinux servers

sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d

cat /etc/pacman.d/mirrorlist

sudo pacman -Syu

echo "################################################################"
echo "###############       mirrorlist updated      ###################"
echo "################################################################"

# Xserver install

echo    "################################################################"
echo    "####################   1. ATI       ############################"
echo    "####################   2. NVIDIA    ############################"
echo    "####################   3. INTEL     ############################"
echo    "####################   4. VIRTUAL   ############################"
echo    "####################   5. NONE      ############################"
echo -e "################################################################\n"
read -p "Choose the target GPU system: " GPU_TYPE

case $GPU_TYPE in
    1)
        echo "This is the opensource driver for ATI"

        echo " Xserver setup"

        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm xterm
        sudo pacman -S --noconfirm --needed xf86-video-ati 
        ;;
    2)
        echo "This is the opensource driver for NVIDIA"

        echo " Xserver setup"

        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm xterm
        sudo pacman -S --noconfirm --needed xf86-video-nouveau
        ;;
    3)
        echo "This is the opensource driver for INTEL"

        echo " Xserver setup"

        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm xterm
        sudo pacman -S --noconfirm --needed xf86-video-intel
        ;;
    4)
        echo "This is the opensource driver for VIRTUALBOX"

        echo " Xserver setup"

        sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm xterm 
        echo
        echo "################################################################"
        echo "choose virtualbox-guest-modules-arch in the next installation"
        echo "################################################################"

        sleep 2

        sudo pacman -S virtualbox-guest-utils
        ;; 
	5)
		echo "This is the base XORG install"

		echo " Xserver setup"

		sudo pacman -S --noconfirm --needed xorg-server xorg-apps xorg-xinit xorg-twm xterm
		;;
esac

# Custom LibInput touchpad driver settings 
sudo cp $HOME"/ArchConfig/config/30-touchpad.conf" /etc/X11/xorg.conf.d/

echo "################################################################"
echo "###################    xorg installed     ######################"
echo "################################################################"

package="packer"
command="packer"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else

	sudo pacman -S --noconfirm --needed grep sed bash curl pacman jshon expac

	[ -d /tmp/packer ] && rm -rf /tmp/packer

	mkdir /tmp/packer

	wget https://aur.archlinux.org/cgit/aur.git/plain/PKGBUILD?h=packer

	mv PKGBUILD\?h\=packer /tmp/packer/PKGBUILD

	cd /tmp/packer

	makepkg -i /tmp/packer --noconfirm

	[ -d /tmp/packer ] && rm -rf /tmp/packer

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then
	
	echo "################################################################"
	echo "#########  "$package" has been installed"
	echo "################################################################"

	else

	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!!!!!!!!  "$package" has NOT been installed"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	fi

fi

package="i3-gaps-git"

sudo pacman -S --noconfirm --needed i3blocks i3lock i3status

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else
	packer -S --noconfirm --noedit  $package

	# Just checking if installation was successful
	if pacman -Qi $package &> /dev/null; then
	
	mkdir -p $HOME"/.config/i3"
	cp $HOME"/ArchConfig/config/i3/config" $HOME"/.config/i3/"
	cp $HOME"/ArchConfig/config/i3/lock.sh" $HOME"/.config/i3/"
	chmod +x $HOME"/.config/i3/lock.sh"
	cp $HOME"/ArchConfig/config/compton.conf" $HOME"/.config/"
	cp -r $HOME"/ArchConfig/config/wallpapers" $HOME"/Pictures/"

	cp $HOME"/ArchConfig/config/.xinitrc" $HOME"/"
	cp $HOME"/ArchConfig/config/.bash_profile" $HOME"/"
	cp $HOME"/ArchConfig/config/.Xdefaults" $HOME"/"
	
	echo "################################################################"
	echo "#########  "$package" has been installed"
	echo "################################################################"

	else

	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!!!!!!!!  "$package" has NOT been installed"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

	fi

fi

echo "################################################################"
echo "###################    i3 core installed  ######################"
echo "################################################################"

#software from 'normal' repositories
sudo pacman -S --noconfirm --needed curl bash-completion vim
sudo pacman -S --noconfirm --needed evince firefox xorg-xbacklight
sudo pacman -S --noconfirm --needed gimp git gksu glances
sudo pacman -S --noconfirm --needed gnome-font-viewer python-psutil
sudo pacman -S --noconfirm --needed gparted cmus mpc python-netifaces
sudo pacman -S --noconfirm --needed hardinfo hddtemp htop irssi python-requests
sudo pacman -S --noconfirm --needed lm_sensors lsb-release mpv
sudo pacman -S --noconfirm --needed numlockx xorg-xset libnotify
sudo pacman -S --noconfirm --needed redshift ristretto sane screenfetch scrot 
sudo pacman -S --noconfirm --needed simple-scan simplescreenrecorder sysstat 
sudo pacman -S --noconfirm --needed transmission-cli transmission-gtk rxvt-unicode
sudo pacman -S --noconfirm --needed vnstat wget unclutter network-manager-applet

sudo systemctl enable vnstat
sudo systemctl start vnstat

# Laptop power savings
sudo pacman -S --noconfirm --needed tlp tlp-rdw acpi_call smartmontools ethtool

sudo systemctl enable tlp.service
sudo systemctl enable tlp-sleep.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

#Utilities
sudo pacman -S --noconfirm --needed feh
sudo pacman -S --noconfirm --needed arandr
sudo pacman -S --noconfirm --needed xorg-xrandr
sudo pacman -S --noconfirm --needed gvfs
sudo pacman -S --noconfirm --needed volumeicon

# installation of zippers and unzippers
sudo pacman -S --noconfirm --needed unrar zip unzip sharutils


echo "################################################################"
echo "###################    core software installed  ################"
echo "################################################################"

sudo pacman -S --noconfirm --needed cups cups-pdf ghostscript gsfonts libcups hplip system-config-printer 

systemctl enable org.cups.cupsd.service
systemctl start org.cups.cupsd.service


echo "################################################################"
echo "#########   printer management software installed     ##########"
echo "################################################################"

#Sound
sudo pacman -S --noconfirm --needed pulseaudio pulseaudio-alsa pavucontrol
sudo pacman -S --noconfirm --needed alsa-utils alsa-plugins alsa-lib alsa-firmware
sudo pacman -S --noconfirm --needed gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly gstreamer

echo "################################################################"
echo "#########   sound software software installed   ################"
echo "################################################################"

#Fonts

sudo pacman -S --noconfirm --needed noto-fonts 
sudo pacman -S --noconfirm --needed ttf-ubuntu-font-family
sudo pacman -S --noconfirm --needed ttf-droid --noconfirm
sudo pacman -S --noconfirm --needed ttf-inconsolata

echo "################################################################"
echo "#########   distro specific software installed  ################"
echo "################################################################"