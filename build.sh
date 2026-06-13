#!/bin/bash

## Copyright (C) 2026 tabletseeker <https://github.com/tabletseeker>
## See the LICENSE for file COPYING conditions.

set -x
set -o errexit
set -o nounset
set -o errtrace
set -o pipefail

export PATH="/sbin:/usr/sbin:${PATH}"

SOURCE_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" && pwd )"
PACKAGES="${SOURCE_DIR}/overlays/packages"
DEBOS_CMD=debos

if [ -z "${ARGS+x}" ]; then
    ARGS=""
fi

source "${SOURCE_DIR}/help-steps/variables"
source "${SOURCE_DIR}/help-steps/functions"

while getopts "cdDvizkobsZCKLrR:x:S:e:H:f:g:h:m:M:p:t:u:F:Q:I:T:" opt
do
  case "${opt}" in
    c ) crypt_root=1 ;;
    R ) crypt_password=${OPTARG} ;;
    d ) use_docker=1 ;;
    D ) debug=1 ;;
    v ) verbose=1 ;;
    e ) environment="${OPTARG}" ;;
    H ) hostname="${OPTARG}" ;;
    i ) image_only=1 ;;
    z ) do_compress=1 ;;
    k ) kernel=1 ;;
    b ) no_blockmap=1 ;;
    s ) ssh=1 ;;
    o ) installer=1 ;;
    Z ) zram=1 ;;
    f ) ftp_proxy="${OPTARG}" ;;
    h ) http_proxy="${OPTARG}" ;;
    g ) sign="${OPTARG}" ;;
    M ) mirror="${OPTARG}" ;;
    m ) memory="${OPTARG}" ;;
    p ) password="${OPTARG}" ;;
    t ) device="${OPTARG}" ;;
    u ) username="${OPTARG}" ;;
    F ) filesystem="${OPTARG}" ;;
    Q ) scratchsize="${OPTARG}" ;;
    I ) imagesize="${OPTARG}" ;;
    T ) installersize="${OPTARG}" ;;
    x ) debian_suite="${OPTARG}" ;;
    S ) suite="${OPTARG}" ;;
    C ) contrib=1 ;;
    r ) miniramfs=1 ;;
    K ) keyboard=1;;
    L ) intel_chipset=1;;
    * )
      echo "Unknown option '${opt}'"
      exit 1
      ;;
  esac
	
	if [ -n "${USER_ARGS[$opt]:-}" ]; then
		ARGS+=" ${USER_ARGS[$opt]}${OPTARG:-}"
	fi
done

device_args
package_args
naming_schemes
opt_args
misc_checks
debos_rootfs
debos_installfs
debos_img
debos_misc
debos_compress
debos_sign
