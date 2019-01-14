################################################################################
ARG EMACS_CPP_DEV_VERSION
FROM seelabs/emacs_cpp_dev:${EMACS_CPP_DEV_VERSION}

################################################################################

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get install -y \
        git \
        libprotobuf-dev \
        libssl-dev \
        ninja-build \
        protobuf-compiler \
        tmux \
        vim

################################################################################
ARG BOOST_VERSION

COPY ./scripts/boost.sh .
RUN /bin/bash boost.sh ${BOOST_VERSION} && rm boost.sh
