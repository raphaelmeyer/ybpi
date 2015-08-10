################################################################################

all: ybpi-sdk

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

sdk = poky-glibc-x86_64-rpi-hwup-image-arm1176jzfshf-vfp-toolchain-1.8.sh
image = rpi-hwup-image-raspberrypi.rpi-sdimg

################################################################################

sdk_path = /yocto/rpi-build/tmp/deploy/sdk/$(sdk)
image_path = /yocto/rpi-build/tmp/deploy/images/raspberrypi/$(image)

################################################################################

ybpi-base/.done: ybpi-base/Dockerfile
	-docker rmi ybpi-base
	docker build -t ybpi-base ybpi-base
	touch $@

ybpi-yocto/.done: ybpi-base/.done ybpi-yocto/Dockerfile ybpi-yocto/build-ybpi-sdk.sh
	-docker rmi ybpi-yocto
	docker build -t ybpi-yocto ybpi-yocto
	touch $@

ybpi-sdk/.done: ybpi-base/.done ybpi-sdk/Dockerfile artifacts/$(sdk)
	-docker rmi ybpi-sdk
	cp artifacts/$(sdk) ybpi-sdk/sdk-installer.sh
	docker build -t ybpi-sdk ybpi-sdk
	touch $@

ybpi-yocto-data/.done: ybpi-base/.done ybpi-yocto-data/Dockerfile
	-docker rm -v ybpi-yocto-dataA
	-docker rmi ybpi-yocto-data
	docker build -t ybpi-yocto-data ybpi-yocto-data
	docker create --name ybpi-yocto-data ybpi-yocto-data
	touch $@

################################################################################

build-yocto: ybpi-yocto/.done ybpi-yocto-data/.done
	docker run --rm \
	           --volumes-from ybpi-yocto-data \
	           ybpi-yocto /bin/bash -c "/bin/build-ybpi-sdk.sh"
	docker cp ybpi-yocto-data:$(sdk_path) artifacts/
	docker cp ybpi-yocto-data:$(image_path) artifacts/

artifacts/$(sdk): build-yocto
artifacts/$(image): build-yocto

################################################################################

ybpi-base: ybpi-base/.done

ybpi-yocto: ybpi-yocto/.done
ybpi-yocto-data: ybpi-yocto-data/.done

ybpi-sdk: ybpi-sdk/.done

################################################################################

clean: clean-yocto clean-sdk
	rm -rf $(sdk)

clean-yocto:
	-docker rm -v ybpi-yocto-data
	-docker rmi ybpi-yocto-data
	-docker rmi ybpi-yocto
	rm -rf ybpi-yocto-data/.done
	rm -rf ybpi-yocto/.done

clean-sdk:
	-docker rmi ybpi-sdk
	rm -rf ybpi-sdk/.done

################################################################################

.PHONY: clean
.PHONY: clean-yocto clean-sdk

