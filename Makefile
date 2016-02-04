################################################################################

all: ybpi-sdk yocto-image

################################################################################

sdk = poky-glibc-x86_64-rpi-hwup-image-cortexa7hf-vfp-vfpv4-neon-toolchain-2.0.1.sh
image = rpi-hwup-image-raspberrypi2.rpi-sdimg

ybpi-sdk: ybpi-sdk/.done
yocto-image: artifacts/$(image)
release: ybpi-release

################################################################################

base_version = 1.0.1

deploy = /workspace/rpi-build/tmp/deploy

sdk_deploy = $(deploy)/sdk
sdk_path = $(sdk_deploy)/$(sdk)

image_deploy = $(deploy)/images/raspberrypi2
image_path = $(image_deploy)/$(image)

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

ybpi-release: check-tag ybpi-sdk # artifacts/$(image)
	docker tag raphaelmeyer/ybpi-yocto raphaelmeyer/ypbi-yocto:$(tag)
	docker tag raphaelmeyer/ybpi-sdk raphaelmeyer/ypbi-sdk:$(tag)
	docker push raphaelmeyer/ybpi-yocto:$(tag)
	docker push raphaelmeyer/ybpi-sdk:$(tag)
	echo "TODO upload image to dropbox"

check-tag:
ifndef tag
	$(error "Must specify a tag with make release tag=TAG")
endif

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
	rm -rf artifacts/$(sdk)
	rm -rf artifacts/$(image)

clean-yocto:
	-docker rm -v yocto-workspace
	-docker rmi raphaelmeyer/ybpi-yocto
	rm -rf ybpi-yocto/.done
	rm -rf tools/.yocto-workspace.done

clean-sdk:
	-docker rmi raphaelmeyer/ybpi-sdk
	rm -rf ybpi-sdk/.done

################################################################################

.PHONY: clean
.PHONY: clean-yocto clean-sdk

