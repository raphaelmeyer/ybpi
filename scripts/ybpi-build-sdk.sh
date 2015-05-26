#!/bin/bash

source poky/oe-init-build-env rpi-build

patch -p1 -N --dry-run --silent < /data/rpi-build.patch 2>/dev/null
if [ $? -eq 0 ] ; then
  patch -p1 -N < /data/rpi-build.patch
fi

cp /data/local.conf conf/

bitbake rpi-hwup-image
bitbake rpi-hwup-image -c populate_sdk

