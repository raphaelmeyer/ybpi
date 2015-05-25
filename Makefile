################################################################################

yocto_release = fido

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

toolchain = workspace/rpi-build/tmp/deploy/sdk/poky-glibc-x86_64-rpi-hwup-image-arm1176jzfshf-vfp-toolchain-1.8.sh
image = workspace/rpi-build/tmp/deploy/images/raspberrypi/rpi-hwup-image-raspberrypi.rpi-sdimg

################################################################################

all: ybpi-sdk/.done

################################################################################

ybpi-sdk: ybpi-sdk/.done
ybpi-yocto: ybpi-yocto/.done

ybpi-sdk/.done: ybpi-sdk/Dockerfile $(toolchain) ybpi-sdk/ybpi-entrypoint.sh
	cp $(toolchain) ybpi-sdk/toolchain-install.sh
	docker build -t ybpi-sdk ybpi-sdk
	touch ybpi-sdk/.done

ybpi-yocto/.done: ybpi-yocto/Dockerfile
	docker build -t ybpi-yocto ybpi-yocto
	touch ybpi-yocto/.done

$(toolchain): ybpi-yocto/.done scripts/ybpi-build-sdk.sh scripts/local.conf workspace/poky/.git workspace/meta-raspberrypi/.git
	docker run --rm \
	           -v $(makepath)/workspace:/yocto \
	           -v $(makepath)/scripts:/tmp/scripts \
	           ybpi-yocto /bin/bash -c "/tmp/scripts/ybpi-build-sdk.sh"

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
	rm -rf ybpi-yocto/.done
	rm -rf ybpi-sdk/.done
	rm -rf workspace

.PHONY: clean update
.PHONY: ybpi-sdk ybpi-yocto

