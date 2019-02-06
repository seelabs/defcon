# Docker containers for developing seelabs C++ projects

## Introduction

Docker can be used for many things. It can be a part of a CI system, or it can
be used to deploy services. This project uses docker as part of a development
system. The editor, compiler, debugger, and shells, will all be run within the
docker container.

Compiling a project requires installing several dependencies - including some
that may need to be compiled from source. This project provides a set of docker
images that can quickly installed and used for development. These images are
managed by the `defcon` script. 

This project uses containers for three purposes:

1) "Package containers" used to build dependencies from source. When created,
these containers will build a dependeny and use `checkinstall` to create a
package. The package is kept, and the build files are removed. When creating
other containers, the package is copied from this souce container and installed.
These containers are not meant to be the base of other containers, but are meant
to have their packages copied into other containers and installed. Once created,
they can be uploaded to docker hub for distribution. These layers must not have
an underscore in their name, and the tag must contain the package version as
everything before the first '_' in the tag (or up to the end, if no '_' is
found).

2) "Base containers" used as base layers for a projects deployment and
development containers. These containers have all the dependencies needed to
build a project. The dependencies are installed from either "package containers"
or downloaded using the OS's package manager. These containers are meant to be
used as the base for other development and deployment containers. Once created,
they can be uploaded to docker hub for distribution.

3) "Deployment containers"" build on top the project base containers. These
containers will checkout a project's source code, build the project, remove the
source code and move the built files to an install location within the
container. These may be uploaded to docker hub for distribution.

4) "Development containers" built on top of the project base containers. These
containers will install a set of development tools such as editors, debuggers,
shells, and code navigation tools. They can optionally create an environment
with the user's prefered shell and can bind mount a user's home directory so the
user's customizations will be available within the container. They can
optionally bind mount the x windows socket for gui programs. Development
containers also disable some security options that are needed for running
debuggers (for example, docker disables ptrace by default; this is needed for
gdb). These are custom containers and will not be uploaded to docker hub.

5) Debug deployment containers built on top of the project base containers.
These are like deployment containers, but also install a debugger so problems
can be diagnosed. The source code and intermediate build artifacts are also
available in this container. These are custom containers and will not be
uploaded to docker hub.

There are two types of containers that are used for development. The first is a
generic container that contains a project's dependencies as well as a bash shell
and editors. The second type of container tries to give an environment that
mirrors the one in the host OS. It does this by creating a user in the container
with the same user name, id, and shell as the host OS. It also mounts the user's
home directory into the container so the user's dot files are read. This means
the user's debugger, editor, and shell customizations will be available in the
container. GUI programs can also be run from the docker container.

## Deployment/Development/Debug Containers Customization Points

1) Create a user in the container with a given username, user id, and shell - and add them to sudoers.
The container will log in with this user name, and will set the starting working directory as this user's
home directory. Do this by specifying the command line option -u 'user_name:user_id:user_shell'. Shell defaults
to `bash` is not specified.

2) Specify apt packages to install and packages from "package containers" to
install. Use the `-p` command line option to specify apt packages. Use the -P
command line option to specify "package containers". These packages should be
white space separated.

3) Specify if this container will be used to run gui programs. Use the `-x`
command line option to specify this. Using this option will cause the x-windows
socket to be bind mounted into the container, and the sound device will be
available in the container as well.

4) Specify the base image for for the container. This will be one of the
"Base Container" images.

6) User provided script to run in the container when the image is created. One use
for this would be to build the project and copy the files to install locations.

7) User provided script to run when the container is run.

8) If the container should be removed when shutdown.

After a crating a container's, a convience script to mount the bind points will
be created. These scripts can be listed by the defcon script. The defcon script
can also be used to remove the image and convience script.

## Developing rippled

`rippled` (TBD: link to github) is the project that modivated building these
docker development containers. It requires an up to date C++ compiler, as well
as a version of boost that is more recent than that included in most package
managers. The two images that are meant to be used for development are
`ripple_dev` and `user_dev_env`.

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
defcon create rippled-dev -r ripple -b develop
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
defcon create user-dev
```

It will default to creating a user with a bash shell. If another shell is
desired, it can be specified with the `-s <shell>` switch. For example, to
specify zsh, use the following command:

```
defcon create user-dev -s zsh
```

### Base

Most user can ignore the base images.

There are several base images: `cpp_dev`, `emacs_cpp_dev`, and
`rippled_dev_base`. These take a very long time to build and should usually be
downloaded from docker hub. However, the `defcon` script can build these by
running the `defcon create base` command. Be mindful of what `CONTAINER_VERSION`
specified for these builds. Most of the time the version should just be +0.1
from the most recent version.

## Running

### `ripple_dev`

Running a container from a `ripple_dev` image created above is done with the
`defcon run` command. The same repository and branch needs to be specified as
well (so multiple images may co-exist). For example, to run a bash shell in a
container created from the `rippled_dev-ripple-develop` image, run the following
command:

```
defcon run rippled-dev -b develop -r ripple
```

### `user_dev_env`

Running a container from a `user_dev_image` image created above is done with the
`defcon run` command. For example, to run a bash shell, run the following command:


```
defcon run user-dev
```

To run with another shell, like zsh, specify the shell with the `-s` switch:


```
defcon run user-dev -s zsh
```

## Notes

Docker containers isolate the container from the host OS, and by default
disable some things that are needed to run development tools such as the gdb
debugger and rr debugger. They also do not expose ports needed to connect a
running rippled to the network. The `defcon run` will enable `SYS_PTRACE` so gdb
can run, it will also set `seccomp=unconfoned` to enable the performance
counters need for `rr`. In addition, it will expose port `51235` to rippled can
connect to the networks. To run GUI programs, it will map the X11 socket into
the container and set the display.

### Emacs Notes

Emacs requires dumping an executable's state (it does this to minimize startup
time). This requires disablinb `randomize_va_space` in the host OS before build
emacs. The script automatically disables and re-enables this before building emacs.

### QT Notes

QT 5.9 builds successfully with docker. However, building 5.10 fails. It appears
this is due to the QT build process requiring some security settings that need
to be disabled when building. Unfortunately, docker only let security settings
to be disabled when running a container, not when building a container. Another
solution for building QT > 5.9 needs to be found.
