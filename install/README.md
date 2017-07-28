# Introduction

Over the years i have blablabla
blablabla this is now the result

## Installation

Currently based on the 2017.07.01-x86\_64.iso
Testing done in QEMU/KVM

### Step 1

1. 	Boot into ISO
* loadkeys us				(us now for basic, later try to change to us-international)
* lsblk					(find device location, /dev/sdX)
2.	export DEVICE\_ID=/dev/sdX
* cfdisk $DEVICE\_ID
4. 	select DOS			(create new DOS partition table)

					(Based on 50GB disk with 2GB RAM)
5. 	New - +2G			(create SWAP partition with size of RAM)
6. 	New - +20G			(create / and set bootable)
7. 	New - +10G			(create /var)
8. 	New - +MAX (18G)		(create /home)

* mkfs.ext4 	"${DEVICE\_ID}2"
* mkfs.ext4 	"${DEVICE\_ID}3"
* mkfs.ext4 	"${DEVICE\_ID}4"
* mkswap 	"${DEVICE\_ID}1"
* swapon	"${DEVICE\_ID}1"
* mount "${DEVICE\_ID}2" /mnt
* mkdir /mnt/var
* mount "${DEVICE\_ID}3" /mnt/var
* mkdir /mnt/home
* mount "${DEVICE\_ID}4" /mnt/home

* pacstrap /mnt base base-devel
* genfstab -U /mnt >> /mnt/etc/fstab
* arch-chroot /mnt /bin/bash

* pacman -S --noconfirm vim
23.	vim /etc/locale.gen 			(uncomment en\_GB, en\_US, nl\_NL.UTF-8)
* locale-gen
* echo LANG=en\_US.UTF-8 > /etc/locale.conf
* export LANG=en\_US.UTF-8
27.	vim /etc/vconsole.conf			(KEYMAP=us, FONT=lat9w-16)

* ln -sf /usr/share/zoneinfo/Europe/Amsterdam /etc/localtime
* hwclock --systohc --utc

30. echo exampleHost > /etc/hostname
31. vim /etc/hosts				(append exampleHost after localhost)

* pacman -S --noconfirm networkmanager
* systemctl enable NetworkManager
* passwd					(enter root password)

* mkinitcpio -p linux

* pacman -S --noconfirm grub
37. grub-install --target=i386-pc --recheck /dev/sdX
* grub-mkconfig -o /boot/grub/grub.cfg

* exit
* reboot
