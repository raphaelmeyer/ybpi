FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

# install tools
RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY toolchain-install.sh /tmp/
RUN bash /tmp/toolchain-install.sh -y
RUN rm -rf /tmp/toolchain-install.sh

# setup user
RUN useradd -ms /bin/bash user
ENV HOME /home/user
USER user

RUN mkdir -p /home/user
WORKDIR /home/user

COPY ybpi-entrypoint.sh /

ENTRYPOINT ["/ybpi-entrypoint.sh"]
CMD ["/bin/bash"]

