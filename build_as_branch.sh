#!/bin/bash

DOCKER_REPO=mattiasegly/base-image
SOURCE_BRANCH=bullseye

#Pull base images
docker pull amd64/debian:$SOURCE_BRANCH
docker pull i386/debian:$SOURCE_BRANCH
docker pull balenalib/rpi-raspbian:$SOURCE_BRANCH

#Start fresh
for ARCH in amd64 386 arm
do
docker image rm $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

#Build and push
for ARCH in amd64 386 arm
do
docker build -f Dockerfile.$ARCH -t $DOCKER_REPO:$SOURCE_BRANCH-$ARCH .
docker push $DOCKER_REPO:$SOURCE_BRANCH-$ARCH
done

#Release specific tag
docker manifest create \
	$DOCKER_REPO:$SOURCE_BRANCH \
	$DOCKER_REPO:$SOURCE_BRANCH-amd64 \
	$DOCKER_REPO:$SOURCE_BRANCH-386 \
	$DOCKER_REPO:$SOURCE_BRANCH-arm

for ARCH in amd64 386 arm
do
docker manifest annotate \
	$DOCKER_REPO:$SOURCE_BRANCH \
	$DOCKER_REPO:$SOURCE_BRANCH-$ARCH --os linux --arch $ARCH
done

docker manifest push --purge \
	$DOCKER_REPO:$SOURCE_BRANCH