# Docker containers for developing rippled and related tools.

## Introduction

Compiling rippled requires installing several dependencies - including some that
need to be compiled from source. This project provides a set of docker
images that can quickly installed and used for rippled development. These
images are managed by the `ripcon` script. The two images that are meant to be
used for development are `ripple_dev` and `user_dev_env`.

`ripple_dev` contains the compilers, debuggers, editors, and library
dependencies needed to develop rippled. It will mount two docker volumes. The
first volume is mounted in the container's `/opt/rippled_bld` directory and
contains the rippled source code (the repository and branch will be specified
when the image is created). The second volume is mounted in the container's
`opt/rippled` directory and holds the rippled config file and database files. If
these volumes do not exist, they will automatically be created when the
container is created. Since they are docker volumes, these will not be lost if
the container is rebuilt (with a newer boost library for instance). They may
also be mounted into other containers.

`user_dev_env` creates a user in the container with the same user name, user id,
and shell as the user in the host os. It also mounts the user's home directory
from the host os into the container. Since the home directory is available, the
shell will read the same dot files as the host os, so the environment should be
as productive as if working in the host directory directly (just with different
compilers and libraries installed).

## Creating images

### `ripple_dev`

Before the `rippled_dev` image can be used, it must be created. This image is
based on the `rippled_dev_base` image, which has already built the tools and
libraries needed for development. It will not take long to create.

The difference between `rippled_dev` and `rippled_dev_base` is the two volumes
in `rippled_dev` for the source code and database files. When building
`rippled_dev`, the github repository and branch need to be specified. This is
done with the `-r <github_repo>` and `-b <git_branch>` command line switches.
The name of the resulting image will be
`rippled_dev-${GITHUB_REPO}-${GIT_BRANCH}`. For example, to build a
`rippled_dev` with the development branch of the ripple repository run the
command:

```
ripcon create rippled-dev -r ripple -b develop
```

The resulting image will be called `rippled_dev-ripple-develop`.

### `user_dev_env`

Before the `user_dev_env` image can be used, it must be created. This image is
based on the `rippled_dev_base` image, which has already built the tools and
libraries needed for development. It will not take long to create. 

`user_dev_env` will mount the user's home directory into the container, as well
as create a user within the container with the same user id and user name as
they have in the host os.

```
ripcon create user-dev
```

It will default to creating a user with a bash shell. If another shell is
desired, it can be specified with the `-s <shell>` switch. For example, to
specify zsh, use the following command:

```
ripcon create user-dev -s zsh
```

### Base

Most user can ignore the base images.

There are several base images: `cpp_dev`, `emacs_cpp_dev`, and
`rippled_dev_base`. These take a very long time to build and should usually be
downloaded from docker hub. However, the `ripcon` script can build these by
running the `ripcon build base` command. Be mindful of what `CONTAINER_VERSION`
specified for these builds. Most of the time the version should just be +0.1
from the most recent version.

## Running

### `ripple_dev`

Running a container from a `ripple_dev` image created above is done with the
`ripcon run` command. The same repository and branch needs to be specified as
well (so multiple images may co-exist). For example, to run a bash shell in a
container created from the `rippled_dev-ripple-develop` image, run the following
command:

```
ripcon run rippled-dev -b develop -r ripple
```

### `user_dev_env`

Running a container from a `user_dev_image` image created above is done with the
`ripcon run` command. For example, to run a bash shell, run the following command:


```
ripcon run user-dev
```

To run with another shell, like zsh, specify the shell with the `-s` switch:


```
ripcon run user-dev -s zsh
```

## Notes

Docker containers isolate the container from the host OS, and by default
disable some things that are needed to run development tools such as the gdb
debugger and rr debugger. They also do not expose ports needed to connect a
running rippled to the network. The `ripcon run` will enable `SYS_PTRACE` so gdb
can run, it will also set `seccomp=unconfoned` to enable the performance
counters need for `rr`. In addition, it will expose port `51235` to rippled can
connect to the networks. To run GUI programs, it will map the X11 socket into
the container and set the display.
