#!/bin/sh

## Copyright (C) 2026 tabletseeker
## See the LICENSE for file COPYING conditions.
set -e
set -x

USERNAME="${1}"
DEBIAN_SUITE="${2}"
ENVIRONMENT="${3}"
KEYBOARD_ENABLED="${4}"
DEST_DIR="/etc/dconf/db/local.d"

[ "$USERNAME" ] || exit 1

# 1. Fix Hostname (Prevents sudo/D-Bus timeouts inside installer context)
HOSTNAME=$(cat /etc/hostname)
echo "127.0.0.1 localhost" > /etc/hosts
echo "127.1.1.1 $HOSTNAME" >> /etc/hosts

# 1a. Building labwc
case "${DEBIAN_SUITE}" in
    "bookworm")
        VERSION="0.6.1"
        WLROOTS_PKG="libwlroots-dev"
        ;;
    "trixie")
        VERSION="0.8.3"
        WLROOTS_PKG="libwlroots-0.18-dev"
        ;;
    "forky"|"sid"|"unstable")
        VERSION="0.20.0"
        WLROOTS_PKG="libwlroots-0.20-dev"
        ;;
    *)
        VERSION="0.20.0"
        WLROOTS_PKG="libwlroots-0.20-dev"
        ;;
esac

echo "Targeting labwc v${VERSION} build on top of ${WLROOTS_PKG}..."

usermod -aG video,render,input,seat root || true

BUILD_DEPS="build-essential meson ninja-build pkg-config git hwdata \
    libxml2-dev libpango1.0-dev \
    libwayland-dev libxkbcommon-dev libinput-dev \
    glib-2.0 libseat-dev libcairo2-dev libpng-dev \
    libxcb-composite0-dev libx11-xcb-dev \
    x11proto-dev libdrm-dev libgbm-dev libegl-dev \
    libsfdo-dev \
    ${WLROOTS_PKG}"

apt-get update && apt-get install --no-install-recommends -y ${BUILD_DEPS}

echo "Cloning and checking out labwc version tag: v${VERSION}"
rm -rf /tmp/labwc
git clone --depth 1 https://github.com/labwc/labwc /tmp/labwc

cd /tmp/labwc
git fetch --tags
git checkout "${VERSION}"

# Only executes if building v0.20.0, fixing the Forky/Sid minor version mismatch.
if [ "${VERSION}" = "0.20.0" ]; then
    sed -i "s/0.20.1/0.20.0/g" meson.build
fi

meson setup build/ --buildtype=release --wrap-mode=nodownload
ninja -C build/
ninja -C build/ install

# Strip debugging symbols out of the custom compiled binary
strip --strip-unneeded /usr/local/bin/labwc || true

echo "Compilation complete. Purging transient build frameworks..."

# Purging
apt-mark auto ${BUILD_DEPS}
apt-get purge -y ${BUILD_DEPS}

apt-get autoremove --purge -y
apt-get clean

# Drop orphaned C/C++ build headers that apt-get purge leaves behind
rm -rf /usr/include/wlroots* /usr/include/wayland* /usr/include/X11 /usr/include/xcb
rm -rf /var/lib/apt/lists/*

rm -rf /tmp/labwc
cd /

# 2. Systemd TTY1 Setup (Forces pure multi-user environment and overrides console fallback)
mkdir -p /etc/systemd/system/getty@tty1.service.d
cat << 'EOF' > /etc/systemd/system/getty@tty1.service.d/override.conf
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --skip-login --noclear -f %I \$TERM
EOF

# Calculate USER_HOME path context for configuration deployments
if [ "$USERNAME" = "root" ]; then
    USER_HOME="/root"
else
    USER_HOME="/home/${USERNAME}"
fi
mkdir -p "$USER_HOME"

# 3. Inject Native Systemd Kiosk Service Profile
echo "Injecting native Systemd Kiosk Service..."

cat > /etc/systemd/system/cage-installer.service << EOF
[Unit]
Description=Labwc Calamares Kiosk Installer Engine
After=systemd-user-sessions.service plymouth-quit-active.service systemd-logind.service dbus.service
Conflicts=getty@tty1.service
StandardInput=tty
StandardOutput=tty
StandardError=tty
TTYPath=/dev/tty1

[Service]
Type=simple
User=root
WorkingDirectory=/root
PAMName=login
Environment=TERM=linux
Environment=XDG_RUNTIME_DIR=/run/user/0
Environment=QT_QPA_PLATFORM=wayland
Environment=GDK_BACKEND=wayland
Environment=CLUTTER_BACKEND=wayland
Environment=QT_IM_MODULE=textinput
Environment=WLR_BACKEND=drm
Environment=XDG_SESSION_TYPE=wayland
Environment=WLR_RENDERER=pixman
# EXPORT INTEGRATION: Passes the compilation parameter down to the runtime script execution
Environment=KEYBOARD_ENABLED="${KEYBOARD_ENABLED}"

ExecStart=/usr/bin/dbus-run-session -- labwc -s /usr/local/bin/launch-kiosk.sh

Restart=on-failure
RestartSec=5
StartLimitIntervalSec=30
StartLimitBurst=3

[Install]
WantedBy=multi-user.target
EOF

# 4. Generate backend launcher pipeline automation engine script (WITH TARGETED HARDWARE DECOUPLING)
cat > /usr/local/bin/launch-kiosk.sh << 'EOF'
#!/bin/sh
exec > /dev/tty1 2>&1
set -x

if [ -x /usr/bin/plymouth ]; then
    plymouth quit --retain-splash || true
    clear
fi

mkdir -p /run/user/0
chmod 700 /run/user/0

echo "=== INITIALIZING FULLSCREEN KIOSK WITH AUTO SCALING ==="
export TERM=linux

# ==================== HARDWARE TARGET DETECTOR LOOP ====================
SCALE_FACTOR=1.0

# Extract strings cleanly to perform device validation checks
SYS_PRODUCT=$(cat /sys/class/dmi/id/product_name 2>/dev/null | tr '[:upper:]' '[:lower:]')
SYS_VENDOR=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null | tr '[:upper:]' '[:lower:]')
V_RES=$(cat /sys/class/drm/card*-*/modes 2>/dev/null | head -n 1 | cut -d'x' -f2)

# Check for explicit hardware profiles or matching high-res fallbacks (QEMU Emulation)
if echo "$SYS_PRODUCT" | grep -qE "surface|xps|zenbook|chromebook|yoga|flex" || \
   echo "$SYS_VENDOR" | grep -qE "lenovo|asus" || \
   [ -n "$V_RES" ] && [ "$V_RES" -ge 1200 ]; then
    echo "🎯 Matching target touch hardware isolated. Enforcing scale vector: 1.7"
    SCALE_FACTOR=1.7
else
    echo "📋 Generic or baseline device detected. Enforcing safe layout base: 1.0"
    SCALE_FACTOR=1.0
fi

export QT_SCALE_FACTOR=${SCALE_FACTOR}
export GDK_SCALE=1
export GDK_DPI_SCALE=${SCALE_FACTOR}
export ELM_SCALE=${SCALE_FACTOR}
export WLR_SCALE=${SCALE_FACTOR}
export GDK_BACKEND=wayland
# ===============================================================================

# ==================== CONDITIONAL KEYBOARD ENGINE LAYER ====================
if [ "$KEYBOARD_ENABLED" = "true" ] || [ "$KEYBOARD_ENABLED" = "1" ] || [ "$KEYBOARD_ENABLED" = "yes" ]; then
    echo "Keyboard parameter active. Launching wvkbd input-method system broker..."
    export QT_IM_MODULE=qtvirtualkeyboard
    
    # We pass an explicit landscape height parameter using a crisp integer token format.
    # This stretches the square buttons taller to prevent flat, squished typing rows.
    # Using a 6-character hex color code avoids alpha-layer validation failures.
    wvkbd-mobintl -L 320 --bg 1a1a1a &
#    sleep 1
else
    echo "Keyboard parameter disabled or false. Suppressing on-screen virtual keyboard."
    unset QT_IM_MODULE
fi
# ===========================================================================

# Startet Calamares im Vollbild
calamares -d

echo "------------------------------------------------------------"
echo "Calamares session closed."
echo "------------------------------------------------------------"
tail -f /dev/null
EOF

chmod +x /usr/local/bin/launch-kiosk.sh

# 4.5 MANDATORY LABWC CONFIGURATION FOR MINBASE
mkdir -p /root/.config/labwc
cat > /root/.config/labwc/rc.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<labwc_config>
  <core>
    <decoration>none</decoration>
    <gap>0</gap>
  </core>
  <windowRules>
    <!-- Forces all windows (Calamares) to open maximized and borderless without desktop bloat -->
    <windowRule identifier="*" match="true">
      <maximized>true</maximized>
      <decorations>no</decorations>
    </windowRule>
  </windowRules>
</labwc_config>
EOF

# Copy the same profile config to skel for consistency
mkdir -p /etc/skel/.config/labwc
cp /root/.config/labwc/rc.xml /etc/skel/.config/labwc/rc.xml

# 5. Enable Service and mask conflicting targets natively
systemctl enable cage-installer.service
systemctl mask getty@tty1.service
systemctl set-default multi-user.target

# 6. Apply input profile parameters for Virtual Keyboards (Conditional Option)
if [ "$KEYBOARD_ENABLED" = "true" ]; then
    mkdir -p "$USER_HOME/.config/wvkbd" || true
    mkdir -p /etc/skel/.config/wvkbd || true
fi

# 7. Re-link and Regenerate Mobian Boot Theme Structures
echo "Re-linking Mobian boot branding configurations..."
if [ -x /usr/sbin/plymouth-set-default-theme ]; then
    plymouth-set-default-theme mobian || true
fi
if [ -x /usr/sbin/update-initramfs ]; then
    update-initramfs -u -k all || true
fi

# 9. Clean Up
apt-get autoremove --purge -y
apt-get clean
rm -rf /var/lib/apt/lists/*

sync
echo "Zeroing free space for maximum compression..."
dd if=/dev/zero of=/zeros bs=1M conv=fsync || true
sync
rm -f /zeros
sync


