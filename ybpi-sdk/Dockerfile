FROM ybpi-base

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY sdk-installer.sh /tmp/
RUN bash /tmp/sdk-installer.sh -y
RUN rm -rf /tmp/sdk-installer.sh

USER user

VOLUME ["/workspace"]
WORKDIR /workspace

COPY ybpi-entrypoint.sh /
ENTRYPOINT ["/ybpi-entrypoint.sh"]
CMD ["/bin/bash"]

