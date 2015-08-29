FROM ybpi-base

MAINTAINER Raphael Meyer <raphael.meyer@bbv.ch>

USER root

RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY sdk-installer.sh /tmp/
RUN bash /tmp/sdk-installer.sh -y
RUN rm -rf /tmp/sdk-installer.sh

USER user

COPY ybpi-entrypoint.sh /
ENTRYPOINT ["/ybpi-entrypoint.sh"]
CMD ["/bin/bash"]

