#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

# setup zram mounts
cat >>/etc/fstab << EOF
/dev/zram1 /tmp     ext4 defaults,strictatime 0 0
/dev/zram2 /var/tmp ext4 defaults,relatime    0 0
EOF
