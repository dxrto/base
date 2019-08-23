MAINTAINER?==@eater.me
# Docker executable to use (default: docker, but img may be used)
DOCKER_EXEC?=docker
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
PACKAGES?=xbps bash ncurses-base shadow
# Directory where chroot should be build
BUILDDIR?=$(PWD)/build
ifeq ($(TOOLBOX),none)
VALID_TOOLBOX?=1
endif
ifeq ($(TOOLBOX),)
override TOOLBOX=none
VALID_TOOLBOX?=1
endif
ifeq ($(TOOLBOX),toybox)
override PACKAGES += toybox
VALID_TOOLBOX?=1
endif
ifeq ($(TOOLBOX),busybox)
override PACKAGES += busybox
VALID_TOOLBOX?=1
endif
ifeq ($(TOOLBOX),default)
override PACKAGES += findutils coreutils diffutils gawk which sed gzip file grep
VALID_TOOLBOX?=1
endif

default: all	

vars:
	@echo MAINTAINER=$(MAINTAINER)
	@echo IMAGE=$(IMAGE)
	@echo ARCH=$(ARCH)
	@echo REPO_ROOT=$(REPO_ROOT)
	@echo REPO=$(REPO)
	@echo TOOLBOX=$(TOOLBOX)
	@echo VALID_TOOLBOX=$(VALID_TOOLBOX)
	@echo PACKAGES=$(PACKAGES)
	@echo BUILDDIR=$(BUILDDIR)

ensure-toolbox:
ifneq ($(VALID_TOOLBOX),1)
	@echo "Please make sure TOOLBOX is none, toybox (default option), busybox or default"
	exit 1
endif

build: ensure-toolbox
	# Create build directory
	mkdir $(BUILDDIR)
	# Create keys database directory
	mkdir -p $(BUILDDIR)/var/db/xbps
	# Import known keys
	cp -r keys $(BUILDDIR)/var/db/xbps
	# Install packages into build directory
	XBPS_ARCH="$(ARCH)" xbps-install -y -r $(BUILDDIR) --repository=$(REPO) -S $(PACKAGES)
	# Create symlinks expected by void
	for dir in lib lib32 sbin bin; do [ -e $(BUILDDIR)/$$dir ] || ln -s usr/$$dir $(BUILDDIR)/$$dir; done
	ln -s usr/lib $(BUILDDIR)/lib64
	# Create default directories expected by void
	for dir in proc sys dev tmp run; do [ -d $(BUILDDIR)/$$dir ] || mkdir $(BUILDDIR)/$$dir; done
ifeq ($(TOOLBOX),toybox)
	# Create toybox symlinks
	xbps-uchroot $(BUILDDIR) /bin/toybox | sed 's:\s:\n:g' | grep -v '^$$' | while read i; do [ -e $(BUILDDIR)/usr/bin/$$i ] || ln -s /bin/toybox $(BUILDDIR)/usr/bin/$$i; done
endif
ifeq ($(TOOLBOX),busybox)
	# Create busybox symlinks
	xbps-uchroot $(BUILDDIR) /bin/busybox -- --list | while read i; do [ -e $(BUILDDIR)/usr/bin/$$i ] || ln -s /bin/busybox $(BUILDDIR)/usr/bin/$$i; done
endif
	# Remove xbps cache dir
	rm -rf $(BUILDDIR)/var/cache/xbps
	# Import custom bashrc
	cp files/bashrc.bash $(BUILDDIR)/etc/bash/bashrc.d/docker.sh
	# Create os-release file
	cp files/os-release $(BUILDDIR)/etc/os-release
	# Create lsb_release file
	cp files/lsb_release $(BUILDDIR)/bin/lsb_release
	chmod +x $(BUILDDIR)/bin/lsb_release
	# Create xbps helpers
	cp files/xbps-remote $(BUILDDIR)/bin/xbps-remote
	chmod +x $(BUILDDIR)/bin/xbps-remote
	cp files/xbps-local $(BUILDDIR)/bin/xbps-local
	chmod +x $(BUILDDIR)/bin/xbps-local
	# Create passwd, shadow and group file
	cp files/passwd $(BUILDDIR)/etc/passwd
	cp files/group $(BUILDDIR)/etc/group
	cp files/shadow $(BUILDDIR)/etc/shadow

install: build
	# Import directory as tar (owned by root) into docker
	tar --owner 0 --group 0 -pC $(BUILDDIR) -c . | $(DOCKER_EXEC) import -m '$(IMAGE) initialization from chroot' -c 'LABEL maintainer="$(MAINTAINER)"' - $(IMAGE)

clean:
	# Remove build directory
	rm -rf $(BUILDDIR)

all: install clean
