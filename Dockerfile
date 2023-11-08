FROM ubuntu:22.04

ENV CC=clang BB=meson SANITIZER=none

RUN apt-get update && \
    apt-get install -y python3-pyelftools python3-pip \
    libcap-dev libseccomp-dev ninja-build \
    pkg-config \
    clang-14 lldb-14 lld-14 clang-format-14 clang-tidy-14 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100 && \
    update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-14 100 && \
    update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-14 100 && \
    update-alternatives --install /usr/bin/run-clang-tidy run-clang-tidy /usr/bin/run-clang-tidy-14 100 && \
    pip3 install meson

COPY . /app
WORKDIR /app
RUN meson setup -Duse_libcap=enabled \
                -Duse_seccomp=true \
                -Dbuild_manpages=disabled \
                -Dtests=true \
                -Duse_fuzzing=true \
                -Db_sanitize="${SANITIZER}" \
                build && \
    ninja -C build

WORKDIR /app/build

CMD meson test -v fuzz-dumpelf
