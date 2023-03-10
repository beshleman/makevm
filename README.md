# A container for making Debian images for VMs

NEVER RUN THIS CONTAINER IN PRIVILEGED MODE.

The container creates images for use in kernel developent.

It is a companion repo to [runvm](https://github.com/beshleman/runvm).
See this repo for full examples of making and running VMs.

The VM built is from vagrant, which means it has the following users:

|  username  | password  |
| ---------- | --------- |
| vagrant    | root      |
| vagrant    | vagrant   |

The VM uses the [insecure Vagrant SSH keypair](https://github.com/hashicorp/vagrant/tree/master/keys).

## Usage

Pass a kernel source tree, configuration (URL or file path), and an output file path.

```bash
KERNEL=/path/to/linux/
CONFIG=/path/to/config
OUTPUT=/path/to/output_dir

docker run \
	--network host \
	-v${KERNEL}:${KERNEL} \
	-v${OUTPUT}:${OUTPUT} \
	-it beshleman/makevm \
	${KERNEL} ${CONFIG} ${OUTPUT}
```

## Example

```bash

KERNEL=/data00/projects/vsock/linux/
CONFIG=https://raw.githubusercontent.com/beshleman/configs/master/vsock.x86_64
OUTPUT=$(realpath ./images)
docker run --network host \
	-v${KERNEL}:${KERNEL} \
	-v${OUTPUT}:${OUTPUT} \
	-it makevm \
	${KERNEL} ${CONFIG} ${OUTPUT}

tree ./images

./images/
├── config-6.3.0-rc1+
├── initrd.img-6.3.0-rc1+
├── System.map-6.3.0-rc1+
├── vmlinux
├── debian_bullseye.qcow2
└── vmlinuz-6.3.0-rc1+

0 directories, 6 files
```
