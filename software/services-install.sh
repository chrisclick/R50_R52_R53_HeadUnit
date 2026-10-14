#!/bin/bash
# Installs Power-monitor, Rotarty-encoder

if [ "$EUID" -ne 0 ]; then
  echo "Please run with sudo."
  exit
fi

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

echo "Installation complete."
