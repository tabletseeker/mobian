#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x
set -o errexit

dpkg --install -- /deb/*.deb || apt-get install -f -y

rm -rf /deb
