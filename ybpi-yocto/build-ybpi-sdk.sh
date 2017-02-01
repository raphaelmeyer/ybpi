#!/bin/bash

YOCTO_RELEASE=morty # 2.2

WORKDIR=/workspace
YOCTODIR=${WORKDIR}/poky-${YOCTO_RELEASE}
BUILDDIR=${WORKDIR}/rpi-build

mkdir -p ${YOCTODIR}

cd ${YOCTODIR}
if [ ! -d poky ] ; then
  git clone http://git.yoctoproject.org/git/poky
  cd poky && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi

cd ${YOCTODIR}
if [ ! -d meta-raspberrypi ] ; then
  git clone http://git.yoctoproject.org/git/meta-raspberrypi
  cd meta-raspberrypi && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi

cd ${YOCTODIR}
if [ ! -d meta-ybpi ] ; then
  git clone https://github.com/raphaelmeyer/meta-ybpi.git
  cd meta-ybpi && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi

cd ${YOCTODIR}/poky && git pull
cd ${YOCTODIR}/meta-raspberrypi && git pull
cd ${YOCTODIR}/meta-ybpi && git pull

mkdir -p ${BUILDDIR}
source ${YOCTODIR}/poky/oe-init-build-env ${BUILDDIR}

bitbake-layers add-layer ${YOCTODIR}/meta-raspberrypi
bitbake-layers add-layer ${YOCTODIR}/meta-ybpi

#bitbake ybpi-raspberrypi2-image
#bitbake ybpi-raspberrypi2-image -c populate_sdk

### delete
#bitbake rpi-hwup-image
#bitbake rpi-hwup-image -c populate_sdk

