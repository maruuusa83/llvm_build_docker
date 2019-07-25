FROM alpine:3.10.1

RUN    apk --update add \
         git make cmake clang python zlib

RUN    git clone https://github.com/llvm/llvm-project.git \
    && mkdir -p llvm-project/llvm/build \
    && cd llvm-project/llvm/build \
    && cmake -G "Unix Makefiles" -DCMKE_CXX_COMPILER=clang++ -DCMAKE_C_COMPILER=clang ../ \
    && make -j4
