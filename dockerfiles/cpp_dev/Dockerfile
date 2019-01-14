################################################################################
ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

################################################################################
ARG GCC_VERSION

COPY ./scripts/gcc.sh .
RUN /bin/bash gcc.sh ${GCC_VERSION} && rm gcc.sh

################################################################################
ARG CMAKE_VERSION

COPY ./scripts/cmake.sh .
RUN /bin/bash cmake.sh ${CMAKE_VERSION} && rm cmake.sh

################################################################################
ARG CLANG_VERSION

COPY ./scripts/clang.sh .
RUN /bin/bash clang.sh ${CLANG_VERSION} && rm clang.sh

################################################################################
ARG GDB_VERSION

COPY ./scripts/gdb.sh .
RUN /bin/bash gdb.sh ${GDB_VERSION} && rm gdb.sh
################################################################################
