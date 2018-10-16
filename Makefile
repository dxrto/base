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

default: all	

vars:
	@echo IMAGE=$(IMAGE)
	@echo ARCH=$(ARCH)
	@echo REPO_ROOT=$(REPO_ROOT)
	@echo REPO=$(REPO)
	@echo PACKAGES=$(PACKAGES)
	@echo BUILDDIR=$(BUILDDIR)

build:
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
	for dir in proc sys dev; do [ -d $(BUILDDIR)/$$dir ] || mkdir $(BUILDDIR)/$$dir; done
	# Create toybox symlinks
	xbps-uchroot $(BUILDDIR) /bin/toybox | sed 's:\s:\n:g' | grep -v '^$$' | while read i; do [ -e $(BUILDDIR)/usr/bin/$$i ] || ln -s /bin/toybox $(BUILDDIR)/usr/bin/$$i; done
	# Remove xbps cache dir
	rm -rf $(BUILDDIR)/var/cache/xbps
	# Import custom bashrc
	cp bashrc.bash $(BUILDDIR)/etc/bash/bashrc.d/docker.sh

install: build
	# Import directory as tar (owned by root) into docker
	tar --owner 0 --group 0 -pC $(BUILDDIR) -c . | docker import - $(IMAGE)

clean:
	# Remove build directory
	rm -rf $(BUILDDIR)

all: install clean
