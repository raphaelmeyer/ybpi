#!/bin/bash

YOCTO_RELEASE=pyro # 2.3

WORKDIR=/workspace
YOCTODIR=${WORKDIR}/poky-${YOCTO_RELEASE}

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

cd ${WORKDIR}
source ${YOCTODIR}/poky/oe-init-build-env

bitbake-layers add-layer ${YOCTODIR}/meta-raspberrypi
bitbake-layers add-layer ${YOCTODIR}/meta-ybpi

cat >${WORKDIR}/build/conf/auto.conf <<EOF
MACHINE ?= "raspberrypi2"

GPU_MEM = "256"
VIDEO_CAMERA = "1"
ENABLE_SPI_BUS = "1"
ENABLE_I2C = "1"
EOF

#bitbake ybpi-rpi2-image
#bitbake ybpi-rpi2-image -c populate_sdk

