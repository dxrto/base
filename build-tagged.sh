#!/usr/bin/env bash
IMAGE="${1:-d.xr.to/base}";
MAINTAINER="${2:-=@eater.me}";
for toolbox in "none" "toybox" "busybox" "default"; do
    make IMAGE="${IMAGE}:${toolbox}" TOOLBOX="${toolbox}";
done
docker tag "${IMAGE}:toybox" "${IMAGE}:latest";
make IMAGE="${IMAGE}:glibc" TOOLBOX="toybox" ARCH="x86_64"
