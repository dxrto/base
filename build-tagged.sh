#!/usr/bin/env bash
DOCKER_EXEC="${DOCKER_EXEC:-docker}";
IMAGE="${1:-d.xr.to/base}";
MAINTAINER="${2:-=@eater.me}";

build_dir="$(dirname "$0")/build"
test -d "${build_dir}" && rm -rf  "${build_dir}";

for toolbox in "none" "toybox" "busybox" "default"; do
    make IMAGE="${IMAGE}:${toolbox}" TOOLBOX="${toolbox}" DOCKER_EXEC="${DOCKER_EXEC}" all > "${toolbox}.log";
done
$DOCKER_EXEC tag "${IMAGE}:toybox" "${IMAGE}:latest";
make IMAGE="${IMAGE}:glibc" TOOLBOX="toybox" ARCH="x86_64" DOCKER_EXEC="${DOCKER_EXEC}" all > "glibc.log";
