#!/bin/bash

YOCTO_RELEASE=fido

WORKDIR=/yocto

if [ ! -d poky ] ; then
  git clone http://git.yoctoproject.org/git/poky
  cd poky && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi
cd ${WORKDIR}

if [ ! -d meta-raspberrypi ] ; then
  git clone https://github.com/raphaelmeyer/meta-raspberrypi.git
  cd meta-raspberrypi && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi
cd ${WORKDIR}

cd poky && git pull
cd ${WORKDIR}

cd meta-raspberrypi && git pull
cd ${WORKDIR}

source poky/oe-init-build-env rpi-build

bitbake rpi-hwup-image
bitbake rpi-hwup-image -c populate_sdk

