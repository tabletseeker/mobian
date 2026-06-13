#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

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
echo "Zeroing free space..."
dd if=/dev/zero of=/zero.fill bs=1M conv=fsync || true
sync
rm -f /zero.fill

