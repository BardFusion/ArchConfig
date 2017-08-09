#!/usr/bin/env bash

set -e

source ./ArchConfig/install/999-print-functions.sh
BOOT_TYPE=$([ -d /sys/firmware/efi ] && echo UEFI || echo BIOS)

git clone https://github.com/BardFusion/ArchConfig.git

su
dnf check-update
dnf upgrade
reboot

# RPM fusion free and non-free
dnf install https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
dnf check-update

dnf install gstreamer-plugins-ugly gstreamer-plugins-bad gstreamer-ffmpeg