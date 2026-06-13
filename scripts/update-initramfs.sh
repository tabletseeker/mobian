#/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

# We must mount a devtmpfs to find which device support the LUKS
# rootfs
trap 'umount /dev' EXIT
mount -t devtmpfs none /dev

update-initramfs -u -k all
