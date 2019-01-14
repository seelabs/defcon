# This docker file must be built with the `scripts/build_docker.sh` script or it will fail.

################################################################################
ARG CPP_DEV_VERSION
FROM seelabs/cpp_dev:${CPP_DEV_VERSION}

################################################################################
ARG EMACS_VERSION

COPY ./scripts/emacs.sh .
RUN /bin/bash emacs.sh ${EMACS_VERSION} && rm emacs.sh
################################################################################
