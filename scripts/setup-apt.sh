#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x
set -o errexit

DEBIAN_SUITE=$1
SECURITY=( "bookworm" "trixie" "forky" )
SOURCES_FILE="/etc/apt/sources.list.d/debian.sources"

# Setup modern sources
cat > "${SOURCES_FILE}" << EOF
Types: deb deb-src
URIs: https://deb.debian.org/debian
Suites: ${DEBIAN_SUITE}
## If you want access to contrib and non-free components,
## add " contrib non-free" after "non-free-firmware":
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF

# Add security for stable and testing
if printf "%s\n" "${SECURITY[@]}" | grep -qwo "${DEBIAN_SUITE}"; then
cat >> "${SOURCES_FILE}" << EOF

Types: deb deb-src
URIs: https://security.debian.org/debian-security
Suites: ${DEBIAN_SUITE}-security
Components: main
Enabled: yes
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
fi

# Remove old sources
rm -vf /etc/apt/sources.list
