#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

echo "Stripping server firmware out of the CORE rootfs payload..."
rm -rf /lib/firmware/netronome /usr/lib/firmware/netronome
rm -rf /lib/firmware/mrvl /usr/lib/firmware/mrvl
rm -rf /lib/firmware/liquidio /usr/lib/firmware/liquidio
rm -rf /lib/firmware/qlogic /usr/lib/firmware/qlogic
rm -rf /lib/firmware/cxgb4 /usr/lib/firmware/cxgb4

# 1. Standard Package Cleanup
apt-get -y autoremove --purge
apt-get clean

# 2. CLEANING
rm -rf /var/lib/apt/lists/*
find /var/log -type f -exec truncate -s 0 {} +

# 3. MASK SERVICES
systemctl mask wpa_supplicant-wired@.service
systemctl mask wpa_supplicant-nl80211@.service

# 4. ZERO FREE SPACE (Maximize XZ speed)
sync
echo "Zeroing free space for maximum compression..."
# Using a 4k block size prevents dd from out-running the virtual disk filesystem buffer
dd if=/dev/zero of=/zeros bs=4k conv=fsync || true
sync
rm -f /zeros
sync
