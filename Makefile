################################################################################

all: ybpi-sdk image host-sdk

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

sdk = poky-glibc-x86_64-rpi-hwup-image-cortexa7hf-vfp-vfpv4-neon-toolchain-1.8.sh
image = rpi-hwup-image-raspberrypi2.rpi-sdimg

################################################################################

deploy = /workspace/rpi-build/tmp/deploy

sdk_deploy = $(deploy)/sdk
sdk_path = $(sdk_deploy)/$(sdk)

image_deploy = $(deploy)/images/raspberrypi2
image_path = $(image_deploy)/$(image)

################################################################################

ybpi-base/.done: ybpi-base/Dockerfile
	-docker rmi raphaelmeyer/ybpi-base
	docker build -t raphaelmeyer/ybpi-base ybpi-base
	touch $@

ybpi-yocto/.done: ybpi-base/.done ybpi-yocto/Dockerfile ybpi-yocto/build-ybpi-sdk.sh
	-docker rmi raphaelmeyer/ybpi-yocto
	docker build -t raphaelmeyer/ybpi-yocto ybpi-yocto
	touch $@

ybpi-sdk/.done: ybpi-base/.done ybpi-sdk/Dockerfile ybpi-sdk/ybpi-entrypoint.sh artifacts/$(sdk)
	-docker rmi raphaelmeyer/ybpi-sdk
	cp artifacts/$(sdk) ybpi-sdk/sdk-installer.sh
	docker build -t raphaelmeyer/ybpi-sdk ybpi-sdk
	touch $@

host-sdk/.done: ybpi-base/.done host-sdk/Dockerfile
	-docker rmi raphaelmeyer/host-sdk
	docker build -t raphaelmeyer/host-sdk host-sdk
	touch $@

################################################################################

.yocto-workspace.done: ybpi-base/.done
	-docker rm -v yocto-workspace
	docker create --name yocto-workspace raphaelmeyer/ybpi-base
	touch $@

################################################################################

ybpi-yocto: ybpi-yocto/.done .yocto-workspace.done
	docker run --rm -t --volumes-from yocto-workspace raphaelmeyer/ybpi-yocto \
	  /bin/bash -c "/bin/build-ybpi-sdk.sh"

artifacts/$(image): ybpi-yocto artifacts
	$(eval target := $(shell \
	  docker run --rm -t --volumes-from yocto-workspace \
	    raphaelmeyer/ybpi-yocto readlink $(image_path)))
	docker cp yocto-workspace:$(image_deploy)/$(target) $@

artifacts/$(sdk): ybpi-yocto artifacts
	docker cp yocto-workspace:$(sdk_path) $@

artifacts:
	mkdir -p $@

################################################################################

ybpi-sdk: ybpi-sdk/.done

sdk: artifacts/$(sdk)
image: artifacts/$(image)

################################################################################

clean: clean-yocto clean-sdk clean-base clean-host
	rm -rf artifacts/$(sdk)
	rm -rf artifacts/$(image)

clean-yocto:
	-docker rm -v yocto-workspace
	-docker rmi raphaelmeyer/ybpi-yocto
	rm -rf ybpi-yocto/.done

clean-sdk:
	-docker rmi raphaelmeyer/ybpi-sdk
	rm -rf ybpi-sdk/.done

clean-base:
	-docker rmi raphaelmeyer/ybpi-base
	rm -rf ybpi-base/.done

clean-host:
	-docker rmi raphaelmeyer/host-sdk
	rm -rf host-sdk/.done

################################################################################

.PHONY: clean
.PHONY: clean-yocto clean-sdk clean-base clean-host

