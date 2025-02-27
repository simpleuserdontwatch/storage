#!/bin/sh

# Ensure script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Update system and install necessary packages
apk update && apk upgrade
apk add openrc eudev dbus-x11 xorg-server xfce4 xfce4-terminal lightdm lightdm-gtk-greeter networkmanager 

# Enable required services
rc-update add udev boot
rc-update add dbus default
rc-update add lightdm default
rc-update add networkmanager default

# Configure auto-login for user
mkdir -p /etc/lightdm
cat << EOF > /etc/lightdm/lightdm.conf
[Seat:*]
autologin-user=user
autologin-user-timeout=0
default-user=user
default-user-timeout=0
EOF

# Create a user without a password
adduser -D user
passwd -d user

# Allow user to use sudo
apk add sudo
addgroup user wheel
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel

# Cleanup and reboot
echo "Setup complete! Rebooting..."
sync && reboot
