#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

IMAGE="$1"

[ "${IMAGE}" ] || exit 1

# On an Android device, we can't simply flash a full bootable image: we can only
# flash one partition at a time using fastboot.

BLKDEVS=$(parted -ms "${IMAGE}.img" unit s print | sed '/BYT;/d')
BLKSIZE=$(echo "${BLKDEVS}" | head -1 | cut -d ':' -f 4)
for label in rootfs; do
    PARTSTART=$(echo "${BLKDEVS}" | grep "${label}" | cut -d ':' -f 2 | sed 's/s$//')
    PARTSIZE=$(echo "${BLKDEVS}" | grep "${label}" | cut -d ':' -f 4 | sed 's/s$//')

    # Extract partition
    echo "Extracting ${label} @ ${PARTSTART}"
    dd if="${IMAGE}.img" of="${IMAGE}.${label}.img" bs="${BLKSIZE}" skip="${PARTSTART}" count="${PARTSIZE}"

    # Filesystem images need to be converted to Android sparse images first
    echo "Converting ${label} to sparse image"
    img2simg "${IMAGE}.${label}.img" "${IMAGE}.${label}.simg" && mv "${IMAGE}.${label}.simg" "${IMAGE}.${label}.img"
done

rm "${IMAGE}.img"
