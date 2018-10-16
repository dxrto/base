# `d.xr.to/base`

This is the base image for the d.xr.to repo.


This image is a slimmed down version of the [`voidlinux/voidlinux-musl`](https://hub.docker.com/r/voidlinux/voidlinux-musl) image, from 66MB (or if you build an up-to-date image, 128MB), to no more than 20MB

# Packages

The packages included are `toybox`, `xbps` and `bash`, also is `ncurses-base` included for the terminfo files.

This should create a non-hostile but light weight base environment

# Variables

```makefile
# Name of image
IMAGE ?= d.xr.to/base
# Arch to be used
ARCH ?= x86_64-musl
# Repo root url to be used (/musl will be appended in case of musl based arch)
REPO_ROOT ?= https://alpha.de.repo.voidlinux.org/current
# Absolute repo url
REPO ?= $(REPO_ROOT)$(if $(findstring musl, $(ARCH)),/musl)
# Packages to install
PACKAGES ?= toybox xbps bash ncurses-base
# Directory where chroot should be build
BUILDDIR ?= $(PWD)/build
```

# Building

A makefile has been made to build the docker image

`make build`: will build the root directory in `BUILDDIR`

`make install`: will import the image under the name `IMAGE`

`make [all]`: will build and install the image
