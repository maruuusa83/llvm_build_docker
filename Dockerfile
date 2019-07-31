FROM ubuntu:18.04 AS build-env

ENV LLVMBINPATH /llvm_bin

# install required packages
RUN    apt-get update && apt-get install -y \
         wget make cmake gcc g++ python m4 autoconf automake libtool zlib1g gdebi

# install clang 3.5
## This Dockerfile needs clang 3.5 to build LLVM/clang 3.5 because
## the targets are depends on the old LLVM libs (so newer gcc/clang
## can't compile them).
RUN    mkdir -p /tmp/clang-3.5-inst && cd /tmp/clang-3.5-inst \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-3.5/clang-3.5_3.5.2-3ubuntu1_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-3.5/libclang1-3.5_3.5.2-3ubuntu1_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-3.5/libllvm3.5v5_3.5.2-3ubuntu1_amd64.deb \
    && wget http://archive.ubuntu.com/ubuntu/pool/universe/l/llvm-toolchain-3.5/libclang-common-3.5-dev_3.5.2-3ubuntu1_amd64.deb \
    && gdebi libllvm3.5v5_3.5.2-3ubuntu1_amd64.deb --non-interactive \
    && gdebi libclang1-3.5_3.5.2-3ubuntu1_amd64.deb --non-interactive \
    && gdebi libclang-common-3.5-dev_3.5.2-3ubuntu1_amd64.deb --non-interactive \
    && gdebi clang-3.5_3.5.2-3ubuntu1_amd64.deb --non-interactive \
    && ln -s /usr/bin/clang-3.5 /usr/bin/clang \
    && ln -s /usr/bin/clang++-3.5 /usr/bin/clang++ \
    && rm -r /tmp/clang-3.5-inst/

RUN    wget https://github.com/llvm/llvm-project/archive/llvmorg-3.5.0.tar.gz \
    && tar xzvf llvmorg-3.5.0.tar.gz \
    && mv llvm-project-llvmorg-3.5.0 llvm

# build LLVM 3.5
RUN    mkdir -p /llvm/llvm/build && cd /llvm/llvm/build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LLVMBINPATH \
             -DLLVM_BUILD_EXAMPLES=OFF -DLLVM_BUILD_TESTS=OFF \
             -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang \
             ../ \
    && make -j12 \
    && make install

# build clang 3.5
# To realize clean environment, this dockerfile builds clang 3.5 again
RUN    mkdir -p /llvm/clang/build && cd /llvm/clang/build \
    && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$LLVMBINPATH \
             -DCLANG_BUILD_EXAMPLES=OFF \
             -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang \
             ../ \
    && make -j12 \
    && make install

# move generated files to a new clean environment
FROM ubuntu:18.04
ENV LLVMBINPATH /llvm_bin
ENV PATH=$LLVMBINPATH/bin:$PATH
COPY --from=build-env $LLVMBINPATH $LLVMBINPATH


