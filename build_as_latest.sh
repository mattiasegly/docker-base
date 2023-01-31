#!/bin/bash

DOCKER_REPO=mattiasegly/base-image
SOURCE_BRANCH=bullseye

#Remove old images
for ARCH in amd64 i386 arm32v6 arm32v7 arm64v8
do
docker image rm $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

docker image prune -f

#Pull base images
docker pull balenalib/rpi-debian:$SOURCE_BRANCH
for ARCH in amd64 i386 arm32v7 arm64v8
do
docker pull $ARCH/debian:$SOURCE_BRANCH
done

#Build and push
docker build --no-cache -f Dockerfile.arm32v6 -t $DOCKER_REPO:$SOURCE_BRANCH-arm32v6 .
docker push $DOCKER_REPO:$SOURCE_BRANCH-arm32v6
for ARCH in amd64 i386 arm32v7 arm64v8
do
docker build --no-cache -f Dockerfile -t $DOCKER_REPO:$SOURCE_BRANCH-$ARCH --build-arg ARCH=$ARCH .
docker push $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

#Release specific tag
docker manifest create \
	$DOCKER_REPO:$SOURCE_BRANCH \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-amd64 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-i386 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v6 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v7 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm64v8

docker manifest push --purge \
	$DOCKER_REPO:$SOURCE_BRANCH

#Default "latest" tag
docker manifest create \
	$DOCKER_REPO:latest \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-amd64 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-i386 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v6 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm32v7 \
	--amend $DOCKER_REPO:$SOURCE_BRANCH-arm64v8

docker manifest push --purge \
	$DOCKER_REPO:latest

docker manifest inspect \
	$DOCKER_REPO:latest

#Clean up
docker image rm balenalib/rpi-debian:$SOURCE_BRANCH
for ARCH in amd64 i386 arm32v7 arm64v8
do
docker image rm $ARCH/debian:$SOURCE_BRANCH
done

docker image prune -f
