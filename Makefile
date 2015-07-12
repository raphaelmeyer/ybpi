################################################################################

all: ybpi-yocto

################################################################################

makepath = $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

sdk = artifacts/sdk-install.sh

################################################################################

ybpi-base: ybpi-base/.done

ybpi-yocto: ybpi-yocto/.done
ybpi-yocto-data: ybpi-yocto-data/.done

ybpi-sdk: ybpi-sdk/.done
ybpi-sdk-data: ybpi-sdk-data/.done

ybpi-base/.done: ybpi-base/Dockerfile
	docker build -t ybpi-base ybpi-base
	touch $@

ybpi-yocto/.done: ybpi-base/.done ybpi-yocto/Dockerfile ybpi-yocto/build-ybpi-sdk.sh
	docker build -t ybpi-yocto ybpi-yocto
	touch $@

ybpi-yocto-data/.done: ybpi-base/.done ybpi-yocto-data/Dockerfile
	docker build -t ybpi-yocto-data ybpi-yocto-data
	touch $@

ybpi-sdk-data/.done: ybpi-base/.done ybpi-sdk-data/Dockerfile
	docker build -t ybpi-sdk-data ybpi-sdk-data
	touch $@

$(sdk): ybpi-yocto/.done ybpi-yocto-data/.done
	docker run --rm \
	           --volumes-from ybpi-yocto-data \
	           ybpi-yocto /bin/bash -c "/bin/build-ybpi-sdk.sh"

clean:
	rm -rf ybpi-base/.done
	rm -rf ybpi-yocto/.done
	rm -rf ybpi-yocto-data/.done
	rm -rf ybpi-sdk/.done
	rm -rf ybpi-sdk-data/.done

.PHONY: clean
.PHONY: ybpi-base

