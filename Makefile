################################################################################

yocto_release = fido

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

toolchain = workspace/rpi-build/tmp/deploy/sdk/poky-glibc-x86_64-rpi-hwup-image-arm1176jzfshf-vfp-toolchain-1.8.sh
image = workspace/rpi-build/tmp/deploy/images/raspberrypi/rpi-hwup-image-raspberrypi.rpi-sdimg

################################################################################

all: ybpi-toolchain/.done

################################################################################

ybpi-toolchain: ybpi-toolchain/.done
ybpi-base: ybpi-base/.done

ybpi-toolchain/.done: ybpi-toolchain/Dockerfile $(toolchain)
	cp $(toolchain) ybpi-toolchain/toolchain-install.sh
	cp $(image) ybpi-toolchain/image.rpi-sdimg
	docker build -t ybpi-toolchain ybpi-toolchain
	touch ybpi-toolchain/.done

ybpi-base/.done: ybpi-base/Dockerfile
	docker build -t ybpi-base ybpi-base
	touch ybpi-base/.done

$(toolchain): ybpi-base/.done scripts/ybpi-toolchain.sh workspace/poky/.git workspace/meta-raspberrypi/.git
	docker run --rm \
	           -v $(makepath)/workspace:/home/user/yocto \
	           -v $(makepath)/scripts:/tmp/scripts \
	           ybpi-base /bin/bash -c "/tmp/scripts/ybpi-toolchain.sh"

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
.PHONY: ybpi-toolchain ybpi-base

