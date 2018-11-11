# `d.xr.to/base`

This is the base image for the d.xr.to repo.


This image is a slimmed down version of the [`voidlinux/voidlinux-musl`](https://hub.docker.com/r/voidlinux/voidlinux-musl) image, from 66MB (or if you build an up-to-date image, 128MB), to no more than 20MB

# Docker

```
# For the base install with toybox
docker pull d.xr.to/base
docker pull d.xr.to/base:toybox
# With the busybox toolbox
docker pull d.xr.to/base:busybox
# With the default toolbox
docker pull d.xr.to/base:default
# No toolbox
docker pull d.xr.to/base:none
```

# Toolboxes

There are 4 variants of the base image, all with different or no toolboxes, when none is provided `toybox` is used, when an empty string is provided `none` is used.
the `TOOLBOX` variable is used to specify which toolbox should be used

## `toybox`

Uses toybox for core utils, more info about toybox can be found here: https://landley.net/toybox/about.html

## `busybox`

Uses busybox for core utils, more info about busybox can be found here: https://www.busybox.net/

## `default`

Uses the default core utils, installed with a normal install of VoidLinux, the packages used are: `findutils`, `coreutils`, `diffutils`, `gawk`, `which`, `sed`, `gzip`, `file`, and `grep`

## `none`

No core utils are installed at all.

# Variables

```makefile
# Email address of maintainer
MAINTAINER?==@eater.me
# Name of image
IMAGE?=d.xr.to/base
# Arch to be used
ARCH?=x86_64-musl
# Repo root url to be used (/musl will be appended in case of musl based arch)
REPO_ROOT?=https://alpha.de.repo.voidlinux.org/current
# Absolute repo url
REPO?=$(REPO_ROOT)$(if $(findstring musl, $(ARCH)),/musl)
# Toolbox to be used (toybox, busybox, none or default)
TOOLBOX?=toybox
# Packages to install
PACKAGES?=xbps bash ncurses-base
# Directory where chroot should be build
BUILDDIR?=$(PWD)/build
```

# Building

A makefile has been made to build the docker image

`make build`: will build the root directory in `BUILDDIR`

`make install`: will import the image under the name `IMAGE`

`make [all]`: will build and install the image
