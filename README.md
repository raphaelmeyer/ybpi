# Yoberry Pi Toolchain

## Usage

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


