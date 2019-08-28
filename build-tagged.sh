#!/usr/bin/env bash
IMAGE="${1:-d.xr.to/base}";
MAINTAINER="${2:-=@eater.me}";
DOCKER_BUILDER="${DOCKER_BUILDER:-docker}"
for toolbox in "none" "toybox" "busybox" "default"; do
	make IMAGE="${IMAGE}:${toolbox}" TOOLBOX="${toolbox}" DOCKER_BUILDER="${DOCKER_BUILDER}";
done
docker tag "${IMAGE}:toybox" "${IMAGE}:latest";
make IMAGE="${IMAGE}:glibc" TOOLBOX="toybox" ARCH="x86_64" DOCKER_BUILDER="${DOCKER_BUILDER}"

if [ "${PUSH}" = "y" ]; then
  docker push "${IMAGE}";
fi
