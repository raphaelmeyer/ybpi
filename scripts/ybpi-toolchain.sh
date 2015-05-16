#!/bin/bash

source poky/oe-init-build-env rpi-build

patch -p1 < /tmp/scripts/rpi-build.patch

bitbake rpi-hwup-image
bitbake rpi-hwup-image -c populate_sdk


