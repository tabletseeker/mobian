#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

NONFREE=$1

if [ "${NONFREE}" != "true" ]; then
    exit 0
fi

COMPONENTS="main non-free-firmware"

# Enable non-free-firmware Debian sources but exclude security
sed -i "1,6s/main$/${COMPONENTS}/g" /etc/apt/sources.list.d/debian.sources
