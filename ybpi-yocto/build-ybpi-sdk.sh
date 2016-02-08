#!/bin/bash

YOCTO_RELEASE=jethro

WORKDIR=/workspace

cd ${WORKDIR}
if [ ! -d jethro ] ; then
  git clone http://git.yoctoproject.org/git/jethro
  cd jethro && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi

cd ${WORKDIR}
if [ ! -d meta-raspberrypi ] ; then
  git clone http://git.yoctoproject.org/git/meta-raspberrypi
  cd meta-raspberrypi && git checkout -b ${YOCTO_RELEASE} origin/${YOCTO_RELEASE}
fi

cd ${WORKDIR}
if [ ! -d meta-ybpi ] ; then
  git clone https://github.com/raphaelmeyer/meta-ybpi.git
fi

cd ${WORKDIR}
if [ ! -d rpi-build ] ; then
  git clone https://github.com/raphaelmeyer/rpi-build.git
fi

cd ${WORKDIR}/jethro && git pull
cd ${WORKDIR}/meta-raspberrypi && git pull
cd ${WORKDIR}/meta-ybpi && git pull
cd ${WORKDIR}/rpi-build && git pull

cd ${WORKDIR}
source jethro/oe-init-build-env rpi-build

bitbake rpi-hwup-image
bitbake rpi-hwup-image -c populate_sdk

