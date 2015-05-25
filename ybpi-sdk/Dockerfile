FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.akira.meyer@gmail.com>

RUN apt-get update && apt-get install -y \
  bzip2 \
  make \
  python

RUN apt-get update && apt-get install --no-install-recommends -y cmake

COPY toolchain-install.sh /tmp/
RUN bash /tmp/toolchain-install.sh -y
RUN rm -rf /tmp/toolchain-install.sh

RUN useradd -ms /bin/bash user
ENV HOME /home/user

RUN mkdir -p /home/user/data && chown -R user:user /home/user
RUN mkdir -p /workspace && chown -R user:user /workspace

USER user

VOLUME ["/home/user/data", "/workspace"]
WORKDIR /workspace

COPY ybpi-entrypoint.sh /
ENTRYPOINT ["/ybpi-entrypoint.sh"]
CMD ["/bin/bash"]

