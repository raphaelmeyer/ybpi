FROM raphaelmeyer/base:1.0.1

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
  texinfo \
  wget

COPY build-ybpi-sdk.sh /bin/

USER user

VOLUME ["/workspace"]
WORKDIR /workspace

