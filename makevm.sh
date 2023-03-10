#!/bin/ash

set -eEx

KERNEL_DIR=$1

make_initramfs() {
	ARCH=x86_64
	VER=3.17.0
	MAJOR=v${VER%.*}
	TAR=alpine-minirootfs-${VER}-${ARCH}.tar.gz
	URL=https://dl-cdn.alpinelinux.org/alpine/${MAJOR}/releases/${ARCH}/${TAR}

	wget -c $URL

	WORK_DIR="$(mktemp -d)"
	tar xf ${TAR} -C "${WORK_DIR}"

	# setup the rootfs
	#sudo systemd-nspawn -D "${WORK_DIR}" /sbin/apk add python3 --update-cache

	# make the initramfs
	(
	    find "${WORK_DIR}" -printf "%P\\0" |
	    cpio --directory="${WORK_DIR}" --null --create --verbose \
	    		--owner root:root --format=newc 
	) | lz4c -l > initramfs.img.lz4

	sudo rm -rf "${WORK_DIR}"
}

make_kernel() {
	local KERNEL_CONFIG_URL="https://git.alpinelinux.org/aports/plain/main/linux-lts/virt.x86_64.config"
	olddir=$(pwd)
	cd "${KERNEL_DIR}"
	wget ${KERNEL_CONFIG_URL} -O .linux
	make olddefconfig
	make -j"$(nproc)"
	cd "${olddir}"
}

make_initramfs
make_kernel
make_disk
