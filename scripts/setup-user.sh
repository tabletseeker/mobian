#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

USERNAME=$1
[ "${USERNAME}" ] || exit 1
PASSWORD=$2
[ "${PASSWORD}" ] || exit 1

adduser --gecos "${USERNAME}" --disabled-password --shell /bin/bash "${USERNAME}"
adduser "${USERNAME}" sudo

# Needed for hardware access rights
adduser "${USERNAME}" bluetooth
adduser "${USERNAME}" plugdev

# Feedbackd is only present on Phosh images, let's not fail if it's missing
if getent group feedbackd > /dev/null; then
  adduser "${USERNAME}" feedbackd
fi

echo "${USERNAME}:${PASSWORD}" | chpasswd
