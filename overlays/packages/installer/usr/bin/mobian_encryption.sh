#!/usr/bin/env bash

echo "======================================================="
echo "   STARTING MOBIAN LUKS BOOT REPAIR ENGINE             "
echo "======================================================="

# Finds the active Calamares root target mount point using native mount tables
TARGET=$(findmnt -ln -o TARGET | grep -E "^/tmp/calamares-root-|^/mnt/target_clean" | head -n1)

if [ -z "$TARGET" ] || [ ! -d "$TARGET/etc" ]; then
    echo "CRITICAL: Could not resolve the active Calamares root target filesystem mount sector."
    exit 1
fi

REAL_ROOT_MAP_PATH=$(findmnt -n -o SOURCE "$TARGET")
MAP_NAME=$(basename "$REAL_ROOT_MAP_PATH")

if ! cryptsetup status "$MAP_NAME" >/dev/null 2>&1; then
    echo "-> Profile Detected: Standard unencrypted installation."
    echo "======================================================="
    echo " CONFIGURATION SKIPPED: Passing execution to Calamares "
    echo "======================================================="
    exit 0
fi

REAL_ROOT_UUID=""
REAL_SWAP_UUID=""

# Extract the root partition's true hardware UUID from crypttab
while read -r name dev pass options; do
    [[ "$name" =~ ^# || -z "$name" ]] && continue
    if [ "$name" = "$MAP_NAME" ]; then
        # Strip the 'UUID=' prefix
        REAL_ROOT_UUID="${dev#UUID=}"
    elif [[ "$name" =~ ^(luks-|cryptswap) ]] || [[ "$options" =~ swap ]]; then
        # Capture the raw swap hardware UUID if a swap layer is present in crypttab
        REAL_SWAP_UUID="${dev#UUID=}"
    fi
done < "$TARGET/etc/crypttab"

# Extract the EFI hardware UUID and the active filesystem type from fstab
REAL_EFI_UUID=""
REAL_FS_TYPE=""
while read -r dev mount fstype options dump pass; do
    [[ "$dev" =~ ^# || -z "$dev" ]] && continue
    if [ "$mount" = "/boot/efi" ]; then
        REAL_EFI_UUID="${dev#UUID=}"
    elif [ "$mount" = "/" ]; then
        REAL_FS_TYPE="$fstype"
    fi
done < "$TARGET/etc/fstab"

echo "   Identified Root Map:   /dev/mapper/$MAP_NAME"
echo "   Identified Root UUID:  $REAL_ROOT_UUID"
echo "   Identified Filesystem: $REAL_FS_TYPE"
echo "   Identified EFI UUID:   $REAL_EFI_UUID"
echo "   Identified Swap UUID:  $REAL_SWAP_UUID"
echo "   Staging Directory:     $TARGET"

echo "--> Optimizing system mapping tables to utilize Calamares keys..."

if [ -n "$REAL_SWAP_UUID" ]; then
    # Tell cryptsetup to append the key token against the swap container slot
    cryptsetup luksAddKey --key-slot 1 "/dev/disk/by-uuid/$REAL_SWAP_UUID" "$TARGET/crypto_keyfile.bin" 2>/dev/null

    tee "$TARGET/etc/crypttab" << EOF > /dev/null
${MAP_NAME}  UUID=${REAL_ROOT_UUID}  /crypto_keyfile.bin  luks,initramfs,keyslot=1
luks-${REAL_SWAP_UUID}         UUID=${REAL_SWAP_UUID}         /crypto_keyfile.bin  luks,initramfs,keyslot=1
EOF

    tee "$TARGET/etc/fstab" << EOF > /dev/null
UUID=${REAL_EFI_UUID}                            /boot/efi      vfat    defaults   0 2
/dev/mapper/${MAP_NAME} /              ${REAL_FS_TYPE}    defaults   0 1
/dev/mapper/luks-${REAL_SWAP_UUID}                      none           swap    sw,x-systemd.makefs,x-systemd.device-timeout=10s 0 0
EOF
else
    # MOBILE PHONE / NO-SWAP INSTANCE FALLBACK LAYOUT
    tee "$TARGET/etc/crypttab" << EOF > /dev/null
${MAP_NAME}  UUID=${REAL_ROOT_UUID}  /crypto_keyfile.bin  luks,initramfs,keyslot=1
EOF

    tee "$TARGET/etc/fstab" << EOF > /dev/null
UUID=${REAL_EFI_UUID}                            /boot/efi      vfat    defaults   0 2
/dev/mapper/${MAP_NAME} /              ${REAL_FS_TYPE}    defaults   0 1
EOF
fi

# Configure initramfs tools pattern hooks
tee "$TARGET/etc/cryptsetup-initramfs/conf-hook" << EOF > /dev/null
KEYFILE_PATTERN="/crypto_keyfile.bin"
UMASK=0077
EOF

mkdir -p "$TARGET/etc/initramfs-tools/hooks"
tee "$TARGET/etc/initramfs-tools/hooks/embed_keyfile" << 'EOF' > /dev/null
#!/bin/sh
PREREQ=""
prereqs() { echo "$PREREQ"; }
case $1 in prereqs) prereqs; exit 0;; esac
. /usr/share/initramfs-tools/hook-functions
if [ -f /crypto_keyfile.bin ]; then
    mkdir -p "$DESTDIR"
    cp -p /crypto_keyfile.bin "$DESTDIR/crypto_keyfile.bin"
fi
EOF
chmod +x "$TARGET/etc/initramfs-tools/hooks/embed_keyfile"

echo "--> Aligning system bootloader configuration profiles..."

tee "$TARGET/etc/default/grub" << 'EOF' > /dev/null
GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_DISTRIBUTOR="Mobian"
GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"
GRUB_CMDLINE_LINUX=""
EOF

mkdir -p "$TARGET/etc/default/grub.d"

if [ -n "$REAL_SWAP_UUID" ]; then
    echo "RESUME=/dev/mapper/luks-${REAL_SWAP_UUID}" | tee "$TARGET/etc/initramfs-tools/conf.d/resume" > /dev/null
    rm -f "$TARGET/etc/default/grub.d/99-noresume.cfg"
else
    echo "RESUME=none" | tee "$TARGET/etc/initramfs-tools/conf.d/resume" > /dev/null
    tee "$TARGET/etc/default/grub.d/99-noresume.cfg" << 'EOF' > /dev/null
GRUB_CMDLINE_LINUX_DEFAULT="${GRUB_CMDLINE_LINUX_DEFAULT} noresume"
EOF
fi

echo "======================================================="
echo " COMPLETED: Passing execution to Calamares "
echo "======================================================="
exit 0

