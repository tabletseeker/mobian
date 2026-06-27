#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

echo "Stripping server firmware out of the CORE rootfs payload..."
rm -rf /lib/firmware/netronome /usr/lib/firmware/netronome
rm -rf /lib/firmware/liquidio /usr/lib/firmware/liquidio
rm -rf /lib/firmware/qlogic /usr/lib/firmware/qlogic
rm -rf /lib/firmware/cxgb4 /usr/lib/firmware/cxgb4

# Ensuring Wifi/Bluetooth functionality with older Surface devices
find /lib/firmware/mrvl/ /usr/lib/firmware/mrvl/ -mindepth 1 \
  ! -name '*8797*' \
  ! -name '*8897*' \
  ! -name '*8997*' \
  ! -name 's_uapsta.bin' -delete 2>/dev/null || true

# 1. package cleanup
apt-get -y autoremove --purge
apt-get clean

# 2. apt
rm -rf /var/lib/apt/lists/*
find /var/log -type f -exec truncate -s 0 {} +

# 3. masking services
systemctl mask wpa_supplicant-wired@.service
systemctl mask wpa_supplicant-nl80211@.service

# 4. zero-free
sync
echo "Zeroing free space for maximum compression..."
# Using a 4k block size prevents dd from out-running the virtual disk filesystem buffer
dd if=/dev/zero of=/zeros bs=4k conv=fsync || true
sync
rm -f /zeros
sync
