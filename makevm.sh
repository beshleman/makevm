#!/bin/bash

set -e

usage="$(basename $0) <kernel-dir> <config-uri> <output-dir>"

if [[ $# -ne 3 ]]; then
	echo "${usage}" >&2
	exit 1
fi

download_or_copy_file() {
	local uri="$1"
	local filepath="$2"

	# Check if URI is a URL
	if [[ "$uri" =~ ^https?:// ]]; then
		# Download file from URL to local filepath
		wget "$uri" -O "$filepath"
	else
		# Copy file at URI to local filepath
		cp "$uri" "$filepath"
	fi
}


KERNEL_DIR=$1
CONFIG_URI=$2
OUTDIR="$(realpath $3)"

download_or_copy_file "${CONFIG_URI}" "${KERNEL_DIR}/.config"

olddir=$(pwd)
cd "${KERNEL_DIR}"
make olddefconfig
make -j"$(nproc)"

mkdir -p "${OUTDIR}"
make install
make install INSTALL_PATH="${OUTDIR}"
update-initramfs -c -k all -b "${OUTDIR}"
cp vmlinux "${OUTDIR}"
cd "${olddir}"
