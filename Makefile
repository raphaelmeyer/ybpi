################################################################################

yocto_release = fido

################################################################################

makepath = $(abspath $(lastword $(MAKEFILE_LIST)))

toolchain = poky-glibc-x86_64-rpi-hwup-image-arm1176jzfshf-vfp-toolchain-1.8.sh

################################################################################

all: ybpi-toolchain/.done

################################################################################

ybpi-toolchain/.done: ybpi-toolchain
ybpi-base/.done: ybpi-base

ybpi-toolchain: ybpi-toolchain/Dockerfile # $(toolchain)
	docker build -t ybpi-base ybpi-base
	touch ybpi-toolchain/.done

ybpi-base: ybpi-base/Dockerfile
	docker build -t ybpi-base ybpi-base
	touch ybpi-base/.done

$(toolchain): ybpi-base/.done scripts/ybpi-toolchain.sh
	docker run --rm \
	           -v $(makepath)/workspace:/home/user/yocto \
	           -v $(makepath)/scripts/ybpi-toolchain.sh:/tmp/ybpi-toolchain.sh \
	           ybpi-base /bin/bash -c "/tmp/ybpi-toolchain.sh"

yocto: workspace/poky/.git workspace/meta-raspberrypi/.git

workspace/poky/.git: | workspace
	cd workspace && git clone http://git.yoctoproject.org/git/poky
	cd workspace/poky && git checkout -b $(yocto_release) origin/$(yocto_release)

workspace/meta-raspberrypi/.git: | workspace
	cd workspace && git clone http://git.yoctoproject.org/git/meta-raspberrypi
	cd workspace/meta-raspberrypi && git checkout -b $(yocto_release) origin/$(yocto_release)

workspace:
	mkdir -p workspace

update:
	cd workspace/poky && git pull
	cd workspace/meta-raspberrypi && git pull

clean:
	rm -rf ybpi-base/.done
	rm -rf ybpi-toolchain/.done
	rm -rf workspace

.PHONY: clean update

