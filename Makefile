################################################################################

all: ybpi-sdk

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

sdk = poky-glibc-x86_64-rpi-hwup-image-arm1176jzfshf-vfp-toolchain-1.8.sh
image = rpi-hwup-image-raspberrypi.rpi-sdimg

################################################################################

sdk_path = /yocto/rpi-build/tmp/deploy/sdk/$(sdk)
sdk_image = /yocto/rpi-build/tmp/deploy/images/raspberrypi/$(image)

################################################################################

ybpi-base/.done: ybpi-base/Dockerfile
	$(call DOCKER_RMI,ybpi-base)
	docker build -t ybpi-base ybpi-base
	touch $@

ybpi-yocto/.done: ybpi-base/.done ybpi-yocto/Dockerfile ybpi-yocto/build-ybpi-sdk.sh
	$(call DOCKER_RMI,ybpi-yocto)
	docker build -t ybpi-yocto ybpi-yocto
	touch $@

ybpi-sdk/.done: ybpi-base/.done ybpi-sdk/Dockerfile artifacts/$(sdk)
	$(call DOCKER_RMI,ybpi-sdk)
	cp artifacts/$(sdk) ybpi-sdk/sdk-installer.sh
	docker build -t ybpi-sdk ybpi-sdk
	touch $@

ybpi-yocto-data/.done: ybpi-base/.done ybpi-yocto-data/Dockerfile
	$(call DOCKER_RM_DATA,ybpi-yocto-data)
	$(call DOCKER_RMI,ybpi-yocto-data)
	docker build -t ybpi-yocto-data ybpi-yocto-data
	$(call DOCKER_CREATE,ybpi-yocto-data)
	touch $@

ybpi-sdk-data/.done: ybpi-base/.done ybpi-sdk-data/Dockerfile
	$(call DOCKER_RM_DATA,ybpi-sdk-data)
	$(call DOCKER_RMI,ybpi-sdk-data)
	docker build -t ybpi-sdk-data ybpi-sdk-data
	$(call DOCKER_CREATE,ybpi-sdk-data)
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
ybpi-sdk-data: ybpi-sdk-data/.done

################################################################################

clean: clean-yocto clean-sdk
	rm -rf $(sdk)

clean-yocto:
	$(call DOCKER_RM_DATA,ybpi-yocto-data)
	$(call DOCKER_RMI,ybpi-yocto-data)
	rm -rf ybpi-yocto-data/.done
	$(call DOCKER_RMI,ybpi-yocto)
	rm -rf ybpi-yocto/.done

clean-sdk:
	$(call DOCKER_RM_DATA,ybpi-sdk-data)
	$(call DOCKER_RMI,ybpi-sdk-data)
	rm -rf ybpi-sdk-data/.done
	$(call DOCKER_RMI,ybpi-sdk)
	rm -rf ybpi-sdk/.done

################################################################################

define DOCKER_RMI
if docker images --no-trunc $1 | awk 'NR > 1 { print $$2 }' | grep -q -F "latest" ; then docker rmi $1 ; fi
endef

define DOCKER_CREATE
docker create --name $1 $1
endef

define DOCKER_RM_DATA
if docker ps --no-trunc -a -f name=$1 | awk 'NR > 1 { print $$NF }' | grep -q -w $1 ; then docker rm -v $1 ; fi
endef

.PHONY: clean
.PHONY: clean-yocto clean-sdk

