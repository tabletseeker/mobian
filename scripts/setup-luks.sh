#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

PASSWORD="${1}"
BOOTONROOT="${2}"

PART=""
PARTNR=2

lsblk -n -o kname,pkname,mountpoint
if [ -e /dev/vda1 ]; then
    TARGET_DISK=/dev/vda
else
    TARGET_DISK=$(lsblk -n -o kname,pkname,mountpoint | grep loop | grep '/boot$' | awk '{ print $1 }')
fi

if [ "${BOOTONROOT}" != "true" ]; then
    umount -lf $ROOTDIR/boot $ROOTDIR
else
    umount -lf $ROOTDIR
    PARTNR=1
fi

if echo ${TARGET_DISK} | grep -q p1; then
    PART="p"
    TARGET_DISK="/dev/$(echo ${TARGET_DISK} | sed 's:p1::')"
fi
FILESYSTEM="$(blkid -s TYPE -o value ${TARGET_DISK}${PART}${PARTNR})"

if [ "${FILESYSTEM}" = 'ext4' ]
then
    echo "Minimize ext4 extent for rootfs filesystem to make room for cryptsetup"
    resize2fs -fM ${TARGET_DISK}${PART}${PARTNR}
fi

echo "Setup encryption"
echo "${PASSWORD}" | cryptsetup reencrypt ${TARGET_DISK}${PART}${PARTNR} root --new --reduce-device-size 32M --type luks2 --cipher aes-xts-essiv:sha256 --pbkdf argon2id --key-size 512 --hash sha512

echo "Resize filesystem to fill up partition"
if [ "${FILESYSTEM}" = 'ext4' ]
then
    resize2fs -f /dev/mapper/root
elif [ "${FILESYSTEM}" = 'f2fs' ]
then
    resize.f2fs -s /dev/mapper/root
elif [ "${FILESYSTEM}" = 'btrfs' ]
then
    btrfs filesystem resize max /dev/mapper/root
fi

# remount partitions
mount /dev/mapper/root $ROOTDIR
if [ "${BOOTONROOT}" != "true" ]; then
    mount ${TARGET_DISK}${PART}1 $ROOTDIR/boot
fi

# get root partition UUID
rootfs=$(blkid -s UUID -o value ${TARGET_DISK}${PART}${PARTNR})

echo "Create fstab"
echo "/dev/mapper/root	/	${FILESYSTEM}	defaults,noatime,x-systemd.growfs	0	1" > $ROOTDIR/etc/fstab
if [ "${BOOTONROOT}" != "true" ]; then
    echo "LABEL=boot		/boot	ext4	defaults,noatime,x-systemd.growfs	0	1" >> $ROOTDIR/etc/fstab
fi

echo "Create crypttab"
echo "root UUID=$rootfs none luks,keyscript=/usr/share/initramfs-tools/scripts/unl0kr-keyscript" > $ROOTDIR/etc/crypttab
