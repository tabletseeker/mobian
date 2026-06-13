#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e
# This makes the .img file you flash to the USB bootable
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=debian --recheck --removable
update-grub
