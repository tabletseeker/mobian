#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x
set -o errexit

KERN_REGEX='linux-(image|headers)[-.0-9a-z]+'
DISCARD=($(dpkg --get-selections | grep -Po "${KERN_REGEX}" || true))

if [ ${#DISCARD[@]} -gt 0 ]; then
	apt-get purge ${DISCARD[@]}
	apt-get autoremove --yes
	apt-get clean
fi

dpkg --install -- /kernel/*.deb

update-initramfs -c -k all

rm -rf /kernel
