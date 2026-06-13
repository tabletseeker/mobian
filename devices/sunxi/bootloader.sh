#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -e

#Test if package is installed return 0 if installed
is_package_installed() {
    dpkg -s "$1" &> /dev/null
    return $?
}

#download pinephone vccq package
download_vccq_package() {
    cd /var/lib/
    apt-get download mobian-pinephone-tweaks-vccq
    mv mobian-pinephone-tweaks-vccq*.deb mobian-pinephone-tweaks-vccq.deb
}

create_boot_entry() {
    /usr/sbin/u-boot-update
    echo "Create two entry without and with fdtoverlays"
    extlinux="/boot/extlinux/extlinux.conf"
    if [ ! -f $extlinux ]; then
        echo "No extlinux.conf file: aborting"
        return
    fi
    line_entry=$(grep '^label l0' -n ${extlinux} | cut -d':' -f1)
    if [ -z $line_entry ]; then
        echo "No entry in the extlinux.conf: aborting"
        return
    fi
    count_entries=$(grep "^label" -c ${extlinux})
    if [ $count_entries -gt 1 ]; then
        echo "Multiple entries detected in extlinux.conf: aborting"
        return
    fi

    header="$(head -n$((${line_entry} - 1)) ${extlinux})"
    entry_src="$(tail -n+${line_entry} ${extlinux})"

    line_fdt=$(grep 'fdtoverlays' -n "${extlinux}"| cut -d':' -f1)
    if [ -z $line_fdt ]; then
        echo "No overlays used in the extlinux.conf: aborting"
        return
    fi


    entry="$(head -n$((${line_fdt} - 1)) ${extlinux} | tail -n+${line_entry})
$(tail -n+$((${line_fdt} + 1)) ${extlinux})"

    entryvccq="${entry_src/l0/l$count_entries}"
    entryvccq="${entryvccq/Mobian/Vccq\ Mobian}"

    cat > ${extlinux} << EOF
${header}


${entry}

${entryvccq}
EOF
}

if is_package_installed calamares-settings-mobian ; then 
    #apt-get -y install mobian-pinephone-tweaks-vccq
    #download_vccq_package
    create_boot_entry
fi
