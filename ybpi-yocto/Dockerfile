FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

# install tools
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

# setup user
RUN useradd -ms /bin/bash user
ENV HOME /home/user
USER user

RUN mkdir -p /home/user/yocto
WORKDIR /home/user/yocto

