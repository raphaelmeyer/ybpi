FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

# install tools
RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY toolchain-install.sh /tmp/
COPY image.rpi-sdimg /opt/image/
RUN bash /tmp/toolchain-install.sh -y

# setup user
RUN useradd -ms /bin/bash user
ENV HOME /home/user
USER user

RUN mkdir -p /home/user/yocto
WORKDIR /home/user/yocto

ENTRYPOINT ["/bin/bash", "-c", "source /opt/poky/1.8/environment-setup-arm1176jzfshf-vfp-poky-linux-gnueabi"]

