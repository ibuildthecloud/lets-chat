#!/bin/bash
set -e

IMAGE=ibuildthecloud/lets-chat:${BUILD_NUMBER:-latest}

docker build -t $IMAGE -f docker/Dockerfile .

if [[ "$DOCKER_HUB_USER" && -n "$DOCKER_HUB_PASS" && -n "$DOCKER_HUB_EMAIL" ]]; then
    docker login -u "$DOCKER_HUB_USER" -p "$DOCKER_HUB_PASS" -e "$DOCKER_HUB_EMAIL"

    echo Pushing $IMAGE
    docker push $IMAGE
fi

if [[ -n "$RANCHER_SECRET_KEY" ]]; then
    mkdir -p dist
    sed 's!sdelements/lets-chat:latest!'$IMAGE'!' docker/docker-compose.yml > dist/docker-compose.yml
    rancher-compose -f dist/docker-compose.yml -p lets-chat-${BUILD_NUMBER} up -d
fi
