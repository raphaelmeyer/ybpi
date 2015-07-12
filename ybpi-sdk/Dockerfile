FROM ybpi-base

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY toolchain-install.sh /tmp/
RUN bash /tmp/toolchain-install.sh -y
RUN rm -rf /tmp/toolchain-install.sh

RUN mkdir -p /data /workspace

VOLUME ["/data", "/workspace"]
WORKDIR /workspace

COPY ybpi-entrypoint.sh /
ENTRYPOINT ["/ybpi-entrypoint.sh"]
CMD ["/bin/bash"]

