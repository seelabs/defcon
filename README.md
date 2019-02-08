# DEFCON: DEFining CONtainers for developing C++ projects

## Introduction

Docker can be used for many things. It can be a part of a CI system; it can be
used to deploy services; and it can be used as part of a development system
where the editor, compiler, debugger, and shells, will all be run within the
docker container. Defcon current focuses on using docker for development, though
it may be extended to support deployment.

The `defcon` script is used to create and run containers. A container is usually created by using one of the config files in
the configs directory. For example:

```
scripts/defcon -f configs/user_rippled_dev.json create user
```

To run a container, use the run command instead of the `create` command: For example:

```
scripts/defcon -f configs/user_rippled_dev.json run user
```

Note the `user` parameter in the examples above refers to a predefined package
called `user`. Advanced users can create their own packages that can be
customized with json config file. However, most users will use the existing
`user` package.

Defon requires that the `jq` package to parse json file. On ubuntu run `sudo apt
install jq` to install it.

## Defining Containers with json config files

The `defcon` script is used to create and run containers. The easiest way (tho
not the only way) to specify a container is through a json config file. This
file will specify the base image, the container name, dependencies to install,
and other advanced customizations (such as mounting the user's home directory
and running gui programs). When running or creating packages, the `-f
<json_config_file>` parameter is used to specify the json config file.

The json config file may contain the following keys:

`name` This is the name of docker image to create or run. Example:
```
  "name": "user_dev_rippled:1.3"
```

`base_project` This is the name of the base project to use as the base image
layer. The most important base project is `gcc`. This is a base layer with a
version of gcc installed. It will be used as the base layer for most images.
Example:

```
  "base_project": "gcc"
```

`base_image` This is similar to `base_project` in that it specifies a base image to use for the newly created image. Unlike

`base_project`, the image name is specified directly, rather than computed from a project name. This is useful for building on
top of other images specified with a json file. Example:
```
  "base_image": "seelabs/rippy_base:0.1"
```

`versions`: This is a dictionary of versions to use for other defcon packages,
such as dependencies built from source or base images of other projects. Example:

```
  "versions": {
    "rippled": "1.3",
    "clang": "7",
    "gdb": "8.2"
  }
```

`packages`: This specifies a dictionary of list of packages to install using either a ubuntu's apt package manager, python's pip3 package manager, or
defcon packages of dependencies built from source. Example:
```
{
  "packages": {
    "apt": [
      "git",
      "ninja-build",
      "silversearcher-ag",
      "stow",
      "sudo",
      "tmux",
      "wmctrl",
      "zsh"
    ],
    "defcon": [
      "clang",
      "emacs",
      "gdb"
    ],
    "pip3": [
      "numpy"
     ]
  }
```
 
 `data` This is a list of dictionaries that specify data to add to the
 container. The source of the data may be either a github repository and branch,
 or a file in the on the host system. The '.' directory will be the directory
 the json config file is located in. Absolute paths may also be specified. Note
 that this means these recipies do not have security in mind. They can add any
 file from the host system into the container. The target is the location in the
 container to put the data. Example:

 ```
  "data": [
    {
      "source": {
        "repository": "https://github.com/ripple/rippled.git",
        "branch": "develop"
      },
      "target": "/opt/rippled_bld"
    },
    {
      "source": "./server/rippled.cfg",
      "target": "/opt/rippled/."
    }
  ]
```

`volumes` is a list of directories in the containers that are used as volumes. Example:
```
  "volumes": [
    "/opt/rippled_bld",
    "/opt/rippled"
  ]
```

`mounts` is a dictionary of mount types (currently only `volumes` is supported). The `volumes` key contains a list of dictionaries with
a key for the source volume, and a key for the target directory in the container to mount the volume. Example:
```
  "mounts": {
    "volumes": [
      {
        "source": "rippled_opt_bld",
        "target": "/opt/rippled_bld"
      },
      {
        "source": "rippled_opt",
        "target": "/opt/rippled"
      }
    ]
  }

```

`with_user_home` is a boolean that determines if the user's home directory will be automatically mounted in the container. Setting this flag will also
create a user in the container with the same user id and user name as the user running the `defcon` script. When running the container, the user will
be set to the current user and the user's shell will be run. Example:
```
  "with_user_home": true
```

`with_gui` is a boolean that determines if gui programs can be run from within the container. Setting this will mount the `/tmp/.X11-unix` file within the container and will also set the `-e DISPLAY=unix$DISPLAY` when running the container. Exmaple:
```
  "with_gui": true
```

`with_sound` is a boolean that determines if sound can be played from within the container. Setting this will case a `--define /dev/snd` to be set when running the container. Exmaple:
```
  "with_sound": true
```


`with_debugger` is a boolean that determines if a debugger can be run in the
container (by default, security settings will not allow ptrace to run in the
container, which debugger need to run). Setting this will case
`--cap-add=SYS_PTRACE` to bet set when running the container. Example:
```
  "with_debugger": true
```

`with_reverse_debugger` is a boolean that determines if the reverse debugger rr can be run in the
container (by default, security settings will not allow performance counters to run in the
container, which rr need to run). Setting this will case
`--security-opt seccomp=unconfined` to bet set when running the container. `with_debugger` is _not_ automatically set
and should be set separately. Example:

```
  "with_reverse_debugger": true
```

`ports` is a list of ports to expose from the container. Setting this will add `-p <port>:<port>` for each port specified when running the container (with <port> replaced with the specifed port). Example:

```
  "ports": [
    51235
  ]
```

## Defining containers used to install dependencies from source

"Package containers" are not used as development environments, but are used to
build dependencies from source. When created, these containers will build a
dependeny and use `checkinstall` to create a package. The package is kept, and
the build files are removed. When creating other containers, the package is
copied from this souce container and installed. These containers are not meant
to be the base of other containers, but are meant to have their packages copied
into other containers and installed. Once created, they can be uploaded to
docker hub for distribution. These layers must not have an underscore in their
name, and the tag must contain the package version as everything before the
first '_' in the tag (or up to the end, if no '_' is found).

These container can be specified in a json config file in the `packages['defcon']` dictionary (see section above for specifying json config files).

## Defining base containers

"Base containers" used as base layers for a projects deployment and
development containers. These containers have all the dependencies needed to
build a project. These base containers can be defined either with a json config file,
or if move control is needed, by defining package scripts in the `packages/2` directory.

TBD: Describe how to define package scripts.

## Defining Development containers

"Development containers" built on top of the project base containers. These
containers will install a set of development tools such as editors, debuggers,
shells, and code navigation tools. They can optionally create an environment
with the user's prefered shell and can bind mount a user's home directory so the
user's customizations will be available within the container. They can
optionally bind mount the x windows socket for gui programs. Development
containers also disable some security options that are needed for running
debuggers (for example, docker disables ptrace by default; this is needed for
gdb). These are custom containers and will not be uploaded to docker hub. Use a
json config file to define a development container.


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

When running QT apps withing a container, the following environment needs to be set:

```
export PATH=/usr/local/Qt-5.9.7/bin:${PATH}
export QT_QPA_FONTDIR=/usr/share/fonts/truetype/dejavu
export QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb
```

### TODO:

* Support conan package manager
* This started as a simple bash script that grew to large. I intend to rewrite this in python.
