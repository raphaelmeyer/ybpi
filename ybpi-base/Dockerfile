FROM ubuntu:15.04

MAINTAINER Raphael Meyer <raphael.meyer@bbv.ch>

RUN useradd -ms /bin/bash user
ENV HOME /home/user

RUN mkdir -p /workspace ; chown -R user:user /workspace

USER user

VOLUME ["/workspace"]
WORKDIR /workspace

