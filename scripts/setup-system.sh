#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x
set -e

USERNAME="${1}"
DEBIAN_SUITE="${2}"
KEYBOARD_ENABLED="${3}"
INTEL_CHIPSET="${4}"
DEST_DIR="/etc/dconf/db/local.d"

# 1. Setup hostname
echo "${USERNAME}" > /etc/hostname
echo "127.0.1.1 ${USERNAME}" >> /etc/hosts

# 2. OSK, Power & Hardware Overrides
mkdir -p /etc/dconf/profile

cat > /etc/dconf/profile/user << 'EOF'
user-db:user
system-db:local
EOF

mkdir -p "$DEST_DIR"

cat >> "$DEST_DIR/01-fixes" << EOF
[org/gnome/desktop/a11y/magnifier]
cross-hairs-length=58

[org/gnome/settings-daemon/plugins/media-keys]
active=false

[org/gnome/settings-daemon/plugins/power]
active=false

[org/gnome/settings-daemon/plugins/housekeeping]
donation-reminder-enabled=false

[org/gnome/settings-daemon/peripherals/touchscreen]
orientation-lock=true

[sm/puri/phoc]
auto-maximize=true

[org/gnome/desktop/wm/preferences]
button-layout='appmenu:'

[org/gnome/desktop/interface]
cursor-blink=true
toolkit-accessibility=false

[org/gnome/desktop/input-sources]
sources=[('xkb', 'us')]

[org/sigxcpu/feedbackd]
profile='full'

[org/gnome/control-center]
last-panel='universal-access'

[org/gnome/settings-daemon/plugins/color]
night-light-schedule-automatic=false

[org/gnome/system/location]
enabled=false
EOF

if [ "$KEYBOARD_ENABLED" = "true" ]; then
    echo "Optimizing OSK, Power, and Volume hardware integration..."
    # A. GSETTINGS: System-wide defaults
    cat >> "$DEST_DIR/01-fixes" << EOF

[org/gnome/desktop/a11y/applications]
screen-keyboard-enabled=true

[sm/puri/phosh]
osk-enabled=true

[sm/puri/phosh/osk]
ignore-hw-keyboards=true
EOF

    # B. ENVIRONMENT: Force OSK Icon in Phosh Tray
    # C. SQUEEKBOARD: Bypass Hardware Detection via Skeleton
    mkdir -p /etc/skel/.config/squeekboard
    cat > /etc/skel/.config/squeekboard/config.yml << 'EOF'
---
force_osk: true
EOF
fi

dconf update

# 3. Change plymouth default theme
plymouth-set-default-theme mobian

# Mask unwanted .desktop icons
sed -i '$a NoDisplay=true' /usr/share/applications/nm-connection-editor.desktop 2>/dev/null || true

# Shrink the 100MB Plymouth bloat (Switch to high-compression ZSTD)
if [ -f /etc/initramfs-tools/initramfs.conf ]; then
    sed -i 's/^COMPRESS=.*/COMPRESS=zstd/' /etc/initramfs-tools/initramfs.conf
    sed -i 's/^#COMPRESSLEVEL=.*/COMPRESSLEVEL=19/' /etc/initramfs-tools/initramfs.conf
fi

# Drivers and systemd conflict
mkdir -p /etc/systemd/system.conf.d
cat > /etc/systemd/system.conf.d/01-timeout.conf << EOF
[Manager]
DefaultTimeoutStopSec=5s
EOF

if [ "$INTEL_CHIPSET" = "true" ]; then
# Universal Intel Hardware Button Fix
# This covers Virtual Buttons, HID Event Filters, and SOC button arrays
# found across XPS, Yoga, Zenbook, and modern Chromebooks.
echo "Enabling Pinctrl, HID and SOC Array for Intel Chipsets..."
cat <<EOF >> /etc/initramfs-tools/modules
# The Bus & Pins (Must load first)
intel_lpss_pci
pinctrl_intel
pinctrl_tigerlake
pinctrl_jasperlake
pinctrl_cannonlake
pinctrl_icelake
pinctrl_sunrisepoint

# The Handlers (These turn signals into keys)
intel_vbtn
intel_hid
soc_button_array
sparse_keymap
EOF

# This forces the kernel to wait for the wires before loading the buttons
mkdir -p /etc/modprobe.d
cat <<EOF > /etc/modprobe.d/universal-buttons.conf
# Ensure the base bus and pins are ready before the drivers attempt to bind
softdep soc_button_array pre: pinctrl_intel intel_lpss_pci intel_lpss
softdep intel_vbtn pre: pinctrl_intel intel_lpss intel_vbtn
softdep intel_hid pre: pinctrl_intel intel_lpss intel_hid
EOF
fi

# 4. Rebuild the boot image
# -k all ensures it applies to every kernel version installed
update-initramfs -u -k all

# 5. systemd-firstboot masking
systemctl mask systemd-firstboot.service

# 6. Time and Apt fixes
mkdir -p /var/lib/apt/periodic
touch /var/lib/apt/periodic/update-success-stamp

systemctl enable systemd-timesyncd

echo 'Acquire::Check-Valid-Until "false";' > /etc/apt/apt.conf.d/99-ignore-time

