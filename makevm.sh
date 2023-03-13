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
cp /boot/* ${OUTDIR}/
chmod ag+rw ${OUTDIR}/*
cp vmlinux "${OUTDIR}"
cd "${olddir}"

disk=${OUTDIR}/debian_bullseye.qcow2
URL=https://app.vagrantup.com/generic/boxes/debian11/versions/4.2.8/providers/libvirt.box
wget ${URL} -O libvirt.tar.gz
cleanup() {
	rm -rf libvirt.tar.gz
	rm -rf info.json
	rm -rf metadata.json
	rm -rf Vagrantfile
}
trap cleanup EXIT
mkdir -p $(dirname ${disk})
tar xvf libvirt.tar.gz
mv box.img ${disk}
wget https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant \
	-O ${OUTDIR}/vagrant.key
wget https://raw.githubusercontent.com/hashicorp/vagrant/main/keys/vagrant.pub \
	-O ${OUTDIR}/vagrant.pub
chmod 600 ${OUTDIR}/vagrant.key ${OUTDIR}/vagrant.pub
