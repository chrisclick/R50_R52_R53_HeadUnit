#!/bin/bash
# Script to update and install software on Open Auto Pro on Raspberry Pi

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo."
  exit 1
fi

# Remove fake-hwclock and disable it
echo "Removing and disabling fake-hwclock"
sudo apt-get -y remove fake-hwclock
if [ $? -ne 0 ]; then echo "Failed to remove fake-hwclock"; exit 1; fi
sudo update-rc.d -f fake-hwclock remove
if [ $? -ne 0 ]; then echo "Failed to update-rc.d for fake-hwclock"; exit 1; fi
sudo systemctl disable fake-hwclock
if [ $? -ne 0 ]; then echo "Failed to disable fake-hwclock"; exit 1; fi

# Edit hwclock-set file
echo "Editing hwclock-set file"
sudo sed -i 's/^if \[ -e \/run\/systemd\/system \] ; then$/#if [ -e \/run\/systemd\/system ] ; then/' /lib/udev/hwclock-set
sudo sed -i 's/^exit 0$/#exit 0/' /lib/udev/hwclock-set
sudo sed -i 's/^fi$/#fi/' /lib/udev/hwclock-set
if [ $? -ne 0 ]; then echo "Failed to edit hwclock-set file"; exit 1; fi

# Add required lines to hwclock-set
echo "Adding required lines to hwclock-set"
sudo sed -i 's/\/sbin\/hwclock --rtc=\$dev --systz --badyear/\/sbin\/hwclock --rtc=\$dev --systz --badyear\n\/sbin\/hwclock --rtc=\$dev --systz/' /lib/udev/hwclock-set
if [ $? -ne 0 ]; then echo "Failed to add lines to hwclock-set"; exit 1; fi

# Copy custom splash screens
echo "Copying custom splash screens"
sudo cp /boot/custom/splash1.h264 /usr/share/openautopro/splash1.h264
if [ $? -ne 0 ]; then echo "Failed to copy splash1.h264"; exit 1; fi
sudo cp /boot/custom/splash2.h264 /usr/share/openautopro/splash2.h264
if [ $? -ne 0 ]; then echo "Failed to copy splash2.h264"; exit 1; fi

# Update and full-upgrade system
echo "Updating and upgrading system"
sudo apt update && sudo apt full-upgrade -y
if [ $? -ne 0 ]; then echo "Failed to update and upgrade system"; exit 1; fi

# Install necessary Python packages
echo "Installing necessary Python packages"
sudo pip3 install pyky040
if [ $? -ne 0 ]; then echo "Failed to install pyky040"; exit 1; fi
sudo pip3 install pynput
if [ $? -ne 0 ]; then echo "Failed to install pynput"; exit 1; fi

# Install pigpio
echo "Installing pigpio"
sudo apt-get install pigpio python-pigpio python3-pigpio -y
if [ $? -ne 0 ]; then echo "Failed to install pigpio"; exit 1; fi
sudo python3 -mpip install pigpio_encoder
if [ $? -ne 0 ]; then echo "Failed to install pigpio_encoder"; exit 1; fi

# Reboot the system
echo "Rebooting the system"
sudo reboot