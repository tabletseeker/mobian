#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x

USERNAME="${1}"
DEBIAN_SUITE="${2}"
KEYBOARD_ENABLED="${4}"
DEST_DIR="/etc/dconf/db/local.d"

[ "$USERNAME" ] || exit 1

# 1. Fix Hostname (Prevents sudo/D-Bus timeouts)
HOSTNAME=$(cat /etc/hostname)
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.0.1.1 $HOSTNAME" >> /etc/hosts

# 2. GDM3 Accounts (Forces Phosh over GNOME)
mkdir -p /etc/gdm3
cat > /etc/gdm3/daemon.conf << EOF
[daemon]
AutomaticLoginEnable=True
AutomaticLogin=$USERNAME
WaylandEnable=true
EOF

mkdir -p /var/lib/AccountsService/users
cat > /var/lib/AccountsService/users/$USERNAME << EOF
[User]
Session=phosh
SystemAccount=false
EOF

# 3. Configuration (dconf overrides)
rm -f /home/${USERNAME}/.config/dconf/user
cat >> "$DEST_DIR/01-fixes" << EOF

[org/gnome/desktop/background]
picture-uri='file:///usr/share/backgrounds/custom/wallpaper.svg'
picture-uri-dark='file:///usr/share/backgrounds/custom/wallpaper.svg'
picture-options='zoom'
primary-color='#ff7800'

[org/gnome/desktop/interface]
color-scheme='prefer-dark'
gtk-theme='Adwaita-dark'

[org/gnome/shell]
favorite-apps=['install-mobian.desktop', 'org.gnome.Console.desktop']
EOF

# 4. Sudoers
mkdir -p /etc/sudoers.d
cat > /etc/sudoers.d/calamares << EOF
Defaults env_keep += "WAYLAND_DISPLAY XDG_RUNTIME_DIR QT_QUICK_BACKEND DBUS_SESSION_BUS_ADDRESS"
$USERNAME ALL=(ALL) NOPASSWD: /usr/bin/calamares
EOF
chmod 440 /etc/sudoers.d/calamares

# 5. Launchers
sed -i '$a NoDisplay=true' /usr/share/applications/calamares.desktop 2>/dev/null || true
sed -i '$a NoDisplay=true' /usr/share/applications/nm-connection-editor.desktop 2>/dev/null || true

mkdir -p /usr/share/applications
cat <<EOF > "/usr/share/applications/install-mobian.desktop"
[Desktop Entry]
Name=Install Mobian
Exec=sudo /usr/bin/calamares -d
Icon=calamares
Type=Application
Categories=System;
EOF

# 5. OSK (Bypasses Laptop Hardware)
echo "Applying user settings and OSK hardware bypass..."
    # Fix for the current Live User
    mkdir -p "/home/${USERNAME}/.config/squeekboard"
    echo -e "---\nforce_osk: true" > "/home/${USERNAME}/.config/squeekboard/config.yml"
    chown -R "$USERNAME":"$USERNAME" "/home/${USERNAME}/.config/squeekboard"
    
    # Fix for any future users (via Skeleton)
    mkdir -p /etc/skel/.config/squeekboard
    echo -e "---\nforce_osk: true" > /etc/skel/.config/squeekboard/config.yml
    
    # 1. Kill the directory blocking the service
    rm -rf /usr/lib/systemd/user/mobi.phosh.OSK.service

    # 2. Create the service file from scratch
    cat > /usr/lib/systemd/user/squeekboard.service << 'EOF'
[Unit]
Description=Squeekboard OSK
After=mobi.phosh.Shell.service
[Service]
Type=simple
ExecStart=/usr/bin/squeekboard
Restart=on-failure
[Install]
WantedBy=default.target
EOF

    # Create the symlink Phosh expects
    ln -sf /usr/lib/systemd/user/squeekboard.service /usr/lib/systemd/user/mobi.phosh.OSK.service

# 5B. Squeekboard Hardware Bypass
if [ "$KEYBOARD_ENABLED" = "true" ]; then

    cat >> "$DEST_DIR/01-fixes" << EOF

[org/gnome/desktop/a11y/applications]
screen-keyboard-enabled=true

[sm/puri/phosh]
osk-enabled=true

[sm/puri/phosh/osk]
ignore-hw-keyboards=true
EOF
fi

dconf update

# 6. Permissions & Target (Removed 'seat' group)
/usr/sbin/usermod -aG sudo,video,render,input,tty "$USERNAME"
chown -R "$USERNAME":"$USERNAME" "/home/$USERNAME"
systemctl set-default graphical.target

# 9. Apt Clean up
apt-get autoremove --purge -y
apt-get clean
rm -rf /var/lib/apt/lists/*

sync
echo "Zeroing free space for maximum compression..."
# Using a 4k block size prevents dd from out-running the virtual disk filesystem buffer
dd if=/dev/zero of=/zeros bs=4k conv=fsync || true
sync
rm -f /zeros
sync


