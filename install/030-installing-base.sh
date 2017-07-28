#!/usr/bin/env bash

#======================================================================================
#                                
# Author  : Erik Dubois at http://www.erikdubois.be
# License : Distributed under the terms of GNU GPL version 2 or later
# 
# AS ALLWAYS, KNOW WHAT YOU ARE DOING.
#======================================================================================

set -e

echo "################################################################"
echo "####             Installing reflector                        ###"
echo "################################################################"


# installing refector to test wich servers are fastest
sudo pacman -S --noconfirm --needed reflector


echo "################################################################"
echo "####   finding fastest servers be patient for the world      ###"
echo "################################################################"

# finding the fastest archlinux servers

sudo reflector -l 100 -f 50 --sort rate --threads 5 --verbose --save /tmp/mirrorlist.new && rankmirrors -n 0 /tmp/mirrorlist.new > /tmp/mirrorlist && sudo cp /tmp/mirrorlist /etc/pacman.d


echo "################################################################"
echo "####       fastest servers  saved                            ###"
echo "################################################################"


cat /etc/pacman.d/mirrorlist


sudo pacman -Syu


echo "################################################################"
echo "###############       mirrorlist updated      ###################"
echo "################################################################"

#======================================================================================
#                                
# Author  : Erik Dubois at http://www.erikdubois.be
# License : Distributed under the terms of GNU GPL version 2 or later
# 
# AS ALLWAYS, KNOW WHAT YOU ARE DOING.
#======================================================================================

# if you are in a base system with no xserver and desktop...
# this will install xserver

echo    "################################################################"
echo    "####################   1. ATI       ############################"
echo    "####################   2. NVIDIA    ############################"
echo    "####################   3. INTEL     ############################"
echo    "####################   4. VIRTUAL   ############################"
echo -e "################################################################"
read -p "Choose the target GPU system: " GPU_TYPE

case $GPU_TYPE in
    1)
        echo "This is the opensource driver for ATI"

        echo " Xserver setup"

        sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
        sudo pacman -S xf86-video-ati --noconfirm --needed 
        ;;
    2)
        echo "This is the opensource driver for NVIDIA"

        echo " Xserver setup"

        sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
        sudo pacman -S xf86-video-nouveau --noconfirm --needed
        ;;
    3)
        echo "This is the opensource driver for INTEL"

        echo " Xserver setup"

        sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
        sudo pacman -S xf86-video-intel --noconfirm --needed
        ;;
    4)
        echo "This is the opensource driver for VIRTUALBOX"

        echo " Xserver setup"

        sudo pacman -S xorg-server xorg-apps xorg-xinit xorg-twm xterm --noconfirm --needed
        echo
        echo "################################################################"
        echo "choose virtualbox-guest-modules-arch in the next installation"
        echo "################################################################"

        sleep 2

        sudo pacman -S virtualbox-guest-utils
        ;; 
esac

echo "################################################################"
echo "###################    xorg installed     ######################"
echo "################################################################"

#======================================================================================
# 
# Author  : Erik Dubois at http://www.erikdubois.be
# License : Distributed under the terms of GNU GPL version 2 or later
# 
# AS ALLWAYS, KNOW WHAT YOU ARE DOING.
#======================================================================================

sudo pacman -S --needed --noconfirm wget git

########################################
########    P A C K E R         ########
########################################


# source : http://www.ostechnix.com/install-packer-arch-linux-2/

# straight from aur and github


# checking you have everything you need
# normally not needed
# sudo pacman -S base-devel fakeroot jshon expac git wget --noconfirm

#dependencies for packer



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


##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# Website 	: 	http://www.erikdubois.be
#
# Modified by   :   Jasper Smit
# Date          :   27-07-2017
# Modifications :   Changed i3-gaps-next-git to the regular i3-gaps package  
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################


#Core stuff i3

echo "################################################################"
echo "i 3  improved tiling core files"
echo "################################################################"

sudo pacman -S --noconfirm --needed i3lock i3status 




# gnome

echo "################################################################"
echo "j4-dmenu-desktop"   
echo "################################################################"

package="j4-dmenu-desktop"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi packer &> /dev/null; then

		echo "Installing with packer"
		packer -S --noconfirm --noedit  $package

	elif pacman -Qi pacaur &> /dev/null; then
		
		echo "Installing with pacaur"
		pacaur -S --noconfirm --noedit  $package
		 	
	elif pacman -Qi yaourt &> /dev/null; then

		echo "Installing with yaourt"
		yaourt -S --noconfirm $package
			  	
	fi


fi






echo "################################################################"
echo "i3blocks"   
echo "################################################################"

package="i3blocks"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi packer &> /dev/null; then

		echo "Installing with packer"
		packer -S --noconfirm --noedit  $package

	elif pacman -Qi pacaur &> /dev/null; then
		
		echo "Installing with pacaur"
		pacaur -S --noconfirm --noedit  $package
		 	
	elif pacman -Qi yaourt &> /dev/null; then

		echo "Installing with yaourt"
		yaourt -S --noconfirm $package
			  	
	fi

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



echo "################################################################"
echo "i3-gaps"   
echo "################################################################"

package="i3-gaps"

#----------------------------------------------------------------------------------

#checking if application is already installed or else install with aur helpers
if pacman -Qi $package &> /dev/null; then

	echo "################################################################"
	echo "################## "$package" is already installed"
	echo "################################################################"

else

	#checking which helper is installed
	if pacman -Qi packer &> /dev/null; then

		echo "Installing with packer"
		packer -S --noconfirm --noedit  $package

	elif pacman -Qi pacaur &> /dev/null; then
		
		echo "Installing with pacaur"
		pacaur -S --noconfirm --noedit  $package
		 	
	elif pacman -Qi yaourt &> /dev/null; then

		echo "Installing with yaourt"
		yaourt -S --noconfirm $package
			  	
	fi

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





echo "################################################################"
echo "###################    i3 core installed  ######################"
echo "################################################################"

##################################################################################################################
# Written to be used on 64 bits computers
# Author 	    :    Erik Dubois
# Website 	    :    http://www.erikdubois.be
#
# Modified by   :   Jasper Smit
# Date          :   27-07-2017
# Modifications :   Removed unused applications, added additional applications       
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

#software from 'normal' repositories
sudo pacman -S --noconfirm --needed curl bash-completion vim
sudo pacman -S --noconfirm --needed evince firefox
sudo pacman -S --noconfirm --needed gimp git gksu glances
sudo pacman -S --noconfirm --needed gnome-font-viewer
sudo pacman -S --noconfirm --needed gparted
sudo pacman -S --noconfirm --needed hardinfo hddtemp htop irssi
sudo pacman -S --noconfirm --needed lm_sensors lsb-release mpv
sudo pacman -S --noconfirm --needed numlockx 
sudo pacman -S --noconfirm --needed redshift ristretto sane screenfetch scrot 
sudo pacman -S --noconfirm --needed simple-scan simplescreenrecorder sysstat 
sudo pacman -S --noconfirm --needed terminator transmission-cli transmission-gtk
sudo pacman -S --noconfirm --needed vnstat wget unclutter network-manager-applet

sudo systemctl enable vnstat
sudo systemctl start vnstat

###############################################################################################

# installation of zippers and unzippers
sudo pacman -S --noconfirm --needed unrar zip unzip sharutils

###############################################################################################


echo "################################################################"
echo "###################    core software installed  ################"
echo "################################################################"

##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# Website 	: 	http://www.erikdubois.be
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################



sudo pacman -S --noconfirm --needed cups cups-pdf ghostscript gsfonts libcups hplip system-config-printer 

systemctl enable org.cups.cupsd.service
systemctl start org.cups.cupsd.service


echo "################################################################"
echo "#########   printer management software installed     ##########"
echo "################################################################"

##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# Website 	: 	http://www.erikdubois.be
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################



#Sound
sudo pacman -S --noconfirm --needed pulseaudio pulseaudio-alsa pavucontrol
sudo pacman -S --noconfirm --needed alsa-utils alsa-plugins alsa-lib alsa-firmware
sudo pacman -S --noconfirm --needed gst-plugins-good gst-plugins-bad gst-plugins-base gst-plugins-ugly gstreamer



echo "################################################################"
echo "#########   sound software software installed   ################"
echo "################################################################"

##################################################################################################################
# Written to be used on 64 bits computers
# Author 	: 	Erik Dubois
# Website 	: 	http://www.erikdubois.be
#
# Modified by   :   Jasper Smit
# Date          :   27-07-2017
# Modifications :   Removed unused applications and packages
##################################################################################################################
##################################################################################################################
#
#   DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.
#
##################################################################################################################

echo "################################################################"
echo "#########   distro specific software installed  ################"
echo "################################################################"

#Fonts

sudo pacman -S --noconfirm --needed noto-fonts 
sudo pacman -S --noconfirm --needed ttf-ubuntu-font-family
sudo pacman -S --noconfirm --needed ttf-droid --noconfirm
sudo pacman -S --noconfirm --needed ttf-inconsolata

#Utilities
sudo pacman -S --noconfirm --needed feh
sudo pacman -S --noconfirm --needed arandr
sudo pacman -S --noconfirm --needed qt4
sudo pacman -S --noconfirm --needed xorg-xrandr
sudo pacman -S --noconfirm --needed gvfs
sudo pacman -S --noconfirm --needed compton
sudo pacman -S --noconfirm --needed volumeicon