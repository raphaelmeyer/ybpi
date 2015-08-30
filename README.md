# Yoberry Pi Toolchain

## Getting started

### Install the yocto image

There is a pre-built yocto image and toolchain for [Raspberry Pi 2](https://www.raspberrypi.org/products/raspberry-pi-2-model-b/) model.

The yocto image can be downloaded from [here](https://www.dropbox.com/s/aumk061gelm3wd7/rpi-hwup-image-raspberrypi2_2.0.0.rpi-sdimg?raw=1).

Install the image to a SD card and resize the root partition:

    $ sudo dd if=rpi-hwup-image-raspberrypi2_2.0.0.rpi-sdimg of=/dev/sdX
    $ sudo parted /dev/sdX resizepart 2 512M
    $ sudo resize2fs /dev/sdX2

Connect the Raspberry Pi to the network and start up with the installed yocto image.

### Hello world

Create a data container as the build workspace.

    $ docker create --name workspace raphaelmeyer/ybpi-base:2.0.0

Setup a cmake project, e.g. in `/tmp/src` with a `CMakeLists.txt` and a `main.cc`.

    $ cat /tmp/src/CMakeLists.txt
    project (HELLO)
    add_executable(hello main.cc)

    $ cat /tmp/src/main.cc
    #include <iostream>

    int main() {
      std::cout << "hello world\n";
    }

Use the *ybpi-sdk* container to build the hello world application.

    $ docker run --rm -t -v /tmp/src:/home/user/src:ro --volumes-from workspace raphaelmeyer/ybpi-sdk:2.0.0 cmake /home/user/src
    $ docker run --rm -t -v /tmp/src:/home/user/src:ro --volumes-from workspace raphaelmeyer/ybpi-sdk:2.0.0 make

Get the hello world from the workspace container and copy to the Raspberry Pi.

    $ docker cp workspace:/workspace/hello .
    $ scp hello root@[ip address]:

ssh to the raspberry and run the hello world application:

    $ ssh root@[ip address]
    root@raspberrypi2:~# ./hello


### Example project

An more complete example can be found [here](https://github.com/raphaelmeyer/skeleton/).

## Build the containers

The containers and the yocto image are built with a Makefile.
Change the `Makefile` and e.g. `build-ybpi-sdk.sh` in *ybpi-yocto* for your needs.

## Pre-built

### docker containers

* [ybpi-base](https://hub.docker.com/r/raphaelmeyer/ybpi-base/):
  The base container for *ybpi-sdk* and *ybpi-yocto*.
  Also used for data containers holding the build workspaces.
* [ybpi-yocto](https://hub.docker.com/r/raphaelmeyer/ybpi-yocto/):
  This container is used to build the yocto image and the toolchain (sdk) installer.
* [ybpi-sdk](https://hub.docker.com/r/raphaelmeyer/ybpi-sdk/)
  The toolchain (sdk) is installed in this container.

### yocto image

[ybpi image](https://www.dropbox.com/s/aumk061gelm3wd7/rpi-hwup-image-raspberrypi2_2.0.0.rpi-sdimg?raw=1)

