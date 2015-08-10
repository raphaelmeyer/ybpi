FROM ybpi-base

MAINTAINER Raphael Meyer <raphael.meyer@bbv.ch>

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

VOLUME ["/yocto"]
WORKDIR /yocto

