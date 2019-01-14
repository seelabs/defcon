################################################################################
ARG RIPPLED_DEV_BASE_VERSION
FROM seelabs/rippled_dev_base:${RIPPLED_DEV_BASE_VERSION}

################################################################################
# populate the volumes
# /opt/rippled_bld is where the git project will be checked out. This will be its own volume
# /opt/rippled is for the database files and conf file. This will also be its own
#              volume (separate from the bld volume).

ARG GITHUB_REPO
ARG GIT_BRANCH

RUN mkdir -p /opt/rippled_bld && \
    mkdir -p /opt/rippled && \
    cd /opt/rippled_bld && \
    git clone --recursive https://github.com/${GITHUB_REPO}/rippled.git && \
    cd rippled && \
    git checkout ${GIT_BRANCH}
COPY ./server/rippled.cfg /opt/rippled/.
VOLUME /opt/rippled_bld
VOLUME /opt/rippled

################################################################################