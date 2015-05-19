# Yoberry Pi Toolchain

## Image

### Install

    sudo dd if=workspace/rpi-build/tmp/deploy/images/raspberrypi/rpi-hwup-image-raspberrypi.rpi-sdimg of=/dev/sde
    sudo parted /dev/sde resizepart 2 512
    sudo resize2fs /dev/sde2

## Toolchain usage

### interactive shell:
    docker run --rm -it ybpi-toolchain

### cmake example:

File /tmp/src/CmakeList.txt:

    project (HELLO)
    add_executable(hello main.cc)


File /tmp/src/main.cc:

    #include <iostream>

    int main() {
      std::cout << "hello world\n";
    }


Build:

    docker run --rm -t -v /tmp/src:/home/user/src -v /tmp/workspace:/workspace -w /workspace ybpi-toolchain cmake /home/user/src
    docker run --rm -t -v /tmp/src:/home/user/src -v /tmp/workspace:/workspace -w /workspace ybpi-toolchain make




