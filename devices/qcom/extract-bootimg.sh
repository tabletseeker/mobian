#!/bin/sh

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

SCRIPT="$0"
DEVICE="$1"
IMAGE="$2"

[ "$IMAGE" ] || exit 1

CONFIG="$(dirname ${SCRIPT})/configs/${DEVICE}.toml"
if ! [ -f "${CONFIG}" ]; then
    echo "ERROR: No configuration for device type '${DEVICE}'!"
    exit 1
fi

# Extract all supported variants from config
VARIANTS="$(tomlq -r 'foreach .device[] as $dev (0;
    if $dev.variant then
        [$dev.model, $dev.variant] | join("-")
    else
        $dev.model
    end
)' ${CONFIG})"

for variant in ${VARIANTS}; do
    echo "Extracting boot image for variant ${variant}"
    mv "${ROOTDIR}/bootimg-${variant}" "${ARTIFACTDIR}/${IMAGE}.boot-${variant}.img"
done
