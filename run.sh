#!/bin/bash -el

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd $THIS_SCRIPT_DIR

source Docker/build.env

show_help="false"
start="false"
stop="false"

if [[ ${#@} -lt 1 ]]; then
  show_help="true"
fi

for arg in $@
do
  case $arg in
    "--start"     )  start="true"; shift;;
    "--stop"     )  stop="true"; shift;;
    "-h" | "--help"    )  show_help="true"; shift;;
  esac
done

if [[ "${show_help}" == "true" ]]; then
  echo "Usage: ${0} --start   Starts the container. Takes precedence over --stop."
  echo "       ${0} --stop   Stops and deletes the container"
  exit 0
fi

if [[ ${start} == "true" ]]; then
  docker container run --rm -p ${HTTPD_HOST_PORT}:${HTTPD_CONTAINER_PORT} -d --name ${CONTAINER_SHORT_NAME} ${IMAGE_TAG}:${IMAGE_VERSION}

  echo "http://localhost:${HTTPD_HOST_PORT}"
  exit
fi

if [[ ${stop} == "true" ]]; then
  docker stop ${IMAGE_TAG}:${IMAGE_VERSION}
  exit $?
fi