FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

RUN apt-get update && apt-get install -y \
  bzip2 \
  chrpath \
  cpio \
  diffstat \
  g++ \
  gawk \
  git \
  make \
  python \
  texinfo \
  wget

RUN mkdir -p /data /yocto

VOLUME ["/yocto"]
WORKDIR /yocto

