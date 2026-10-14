#!/bin/bash
# Combined script to update and install software on Open Auto Pro on Raspberry Pi, and install Power-monitor, Rotary-encoder

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

# Install tkinter
echo "Installing tkinter"
sudo apt-get install python3-tk -y
if [ $? -ne 0 ]; then echo "Failed to install tkinter"; exit 1; fi

# Directory for custom services
CUSTOM_SERVICE_DIR="/opt/user-services"

# Create directory if it doesn't exist
if [ ! -d "$CUSTOM_SERVICE_DIR" ]; then
    mkdir -p "$CUSTOM_SERVICE_DIR"
    echo "Created directory $CUSTOM_SERVICE_DIR"
fi

echo "Installing power-monitor script"
cp /boot/custom/power-monitor.py "$CUSTOM_SERVICE_DIR/"
chown root:root "$CUSTOM_SERVICE_DIR/power-monitor.py"
chmod +x "$CUSTOM_SERVICE_DIR/power-monitor.py"

echo "Installing rotary-encoder script"
cp /boot/custom/rotary-encoder.py "$CUSTOM_SERVICE_DIR/"
chown root:root "$CUSTOM_SERVICE_DIR/rotary-encoder.py"
chmod +x "$CUSTOM_SERVICE_DIR/rotary-encoder.py"

echo "Installing 12v-monitor script"
cp /boot/custom/12v-monitor.py "$CUSTOM_SERVICE_DIR/"
chown root:root "$CUSTOM_SERVICE_DIR/12v-monitor.py"
chmod +x "$CUSTOM_SERVICE_DIR/12v-monitor.py"

echo "Installing power-monitor service"
cp /boot/custom/power-monitor.service /etc/systemd/system/
chown root:root /etc/systemd/system/power-monitor.service
chmod 644 /etc/systemd/system/power-monitor.service

echo "Installing rotary-encoder service"
cp /boot/custom/rotary-encoder.service /etc/systemd/system/
chown root:root /etc/systemd/system/rotary-encoder.service
chmod 644 /etc/systemd/system/rotary-encoder.service

echo "Installing 12v-monitor service"
cp /boot/custom/12v-monitor.service /etc/systemd/system/
chown root:root /etc/systemd/system/12v-monitor.service
chmod 644 /etc/systemd/system/12v-monitor.service

# Reload systemd to recognize new services
systemctl daemon-reload

# Enable services to start at boot
echo "Enabling services"
systemctl enable power-monitor.service
systemctl enable rotary-encoder.service
systemctl enable 12v-monitor.service
systemctl enable lcd_backlight_control.service

# Start services
echo "Starting services"
systemctl start power-monitor.service
systemctl start rotary-encoder.service
systemctl start 12v-monitor.service

# Reboot the system
echo "Rebooting the system"
sudo reboot

echo "Installation complete."