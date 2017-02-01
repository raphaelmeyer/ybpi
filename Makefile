################################################################################

all: ybpi-sdk ybpi-image

################################################################################

sdk = poky-glibc-x86_64-rpi-hwup-image-cortexa7hf-vfp-vfpv4-neon-toolchain-2.0.1.sh
image = rpi-hwup-image-raspberrypi2.rpi-sdimg

ybpi-sdk: ybpi-sdk/.done
ybpi-image: artifacts/$(image)
release: ybpi-release

################################################################################

base_version = 1.2.0

deploy = /workspace/rpi-build/tmp/deploy

sdk_deploy = $(deploy)/sdk
sdk_path = $(sdk_deploy)/$(sdk)

image_deploy = $(deploy)/images/raspberrypi2
image_path = $(image_deploy)/$(image)

################################################################################

ifdef tag
ybpi-release-image = artifacts/$(patsubst %.rpi-sdimg,%_$(tag).rpi-sdimg,$(image))
endif

################################################################################

ybpi-yocto/.done: ybpi-yocto/Dockerfile ybpi-yocto/build-ybpi-sdk.sh
	-docker rmi raphaelmeyer/ybpi-yocto
	docker build -t raphaelmeyer/ybpi-yocto ybpi-yocto
	touch $@

ybpi-sdk/.done: ybpi-sdk/Dockerfile ybpi-sdk/ybpi-entrypoint.sh artifacts/$(sdk)
	-docker rmi raphaelmeyer/ybpi-sdk
	cp artifacts/$(sdk) ybpi-sdk/sdk-installer.sh
	docker build -t raphaelmeyer/ybpi-sdk ybpi-sdk
	touch $@

################################################################################

ybpi-release: check-tag ybpi-sdk $(ybpi-release-image)
	docker tag raphaelmeyer/ybpi-yocto raphaelmeyer/ybpi-yocto:$(tag)
	docker tag raphaelmeyer/ybpi-sdk raphaelmeyer/ybpi-sdk:$(tag)
	docker push raphaelmeyer/ybpi-yocto:$(tag)
	docker push raphaelmeyer/ybpi-sdk:$(tag)

check-tag:
ifndef tag
	$(error "Must specify a tag with make release tag=TAG")
endif

$(ybpi-release-image): ybpi-image
	test -f "artifacts/$(image)"
	cp artifacts/$(image) $(ybpi-release-image)
	echo "TODO upload image to dropbox"

################################################################################

tools/.yocto-workspace.done:
	-docker rm -v yocto-workspace
	docker create --name yocto-workspace raphaelmeyer/base:$(base_version)
	touch $@

################################################################################

ybpi-yocto: ybpi-yocto/.done tools/.yocto-workspace.done
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

clean: clean-yocto clean-sdk
	rm -rf artifacts

clean-yocto: clean-yocto-workspace
	rm -rf ybpi-yocto/.done
	-docker rmi raphaelmeyer/ybpi-yocto

clean-sdk:
	rm -rf ybpi-sdk/.done
	-docker rmi raphaelmeyer/ybpi-sdk

clean-yocto-workspace:
	rm -rf tools/.yocto-workspace.done
	-docker rm -v yocto-workspace

################################################################################

.PHONY: clean
.PHONY: clean-yocto clean-sdk
.PHONY: clean-yocto-workspace

