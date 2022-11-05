#!/bin/bash -el

CONTAINER_NAME=${CONTAINER_NAME:-"bloggo_not_doggo"}
EXPOSED_PORT=${EXPOSED_PORT:-"80"}

echo "Blog is running on localhost:${EXPOSED_PORT} as container ${CONTAINER_NAME}."
docker run --rm -p ${EXPOSED_PORT}:80 --name ${CONTAINER_NAME} playtechnique/bloggo_not_doggo:latest
