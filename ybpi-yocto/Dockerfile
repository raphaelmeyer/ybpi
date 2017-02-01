FROM raphaelmeyer/base:1.2.0

MAINTAINER Raphael Meyer <raphael.meyer@bbv.ch>

USER root

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
  python3 \
  texinfo \
  vim \
  wget

RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

COPY build-ybpi-sdk.sh /bin/

USER user

VOLUME ["/workspace"]
WORKDIR /workspace

