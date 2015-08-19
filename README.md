# Yoberry Pi Toolchain

## Image

### Install

    sudo dd if=artifacts/raspberrypi/rpi-hwup-image-raspberrypi2-YYYYMMDDHHMM.rootfs.rpi-sdimg of=/dev/sdX
    sudo parted /dev/sdX resizepart 2 [SIZE]
    sudo resize2fs /dev/sdeX

## Toolchain usage

### create data volume for app
    docker create --name ybpi-app ybpi-sdk-data

### interactive shell:
    docker run --volumes-from ybpi-app --rm -it ybpi-sdk

### cmake example:

File /tmp/src/CMakeLists.txt:

    project (HELLO)
    add_executable(hello main.cc)


File /tmp/src/main.cc:

    #include <iostream>

    int main() {
      std::cout << "hello world\n";
    }


Build:

    docker run --rm -t -v /tmp/src:/home/user/src:ro --volumes-from ybpi-app ybpi-sdk cmake /home/user/src
    docker run --rm -t -v /tmp/src:/home/user/src:ro --voluems-from ybpi-app ybpi-sdk make

Get the artifact:

    docker cp ybpi-app:/workspace/hello .



