#!/bin/bash -el

THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd ${THIS_SCRIPT_DIR}

if [[ -z "$BUILDTYPE" ]]; then
  echo "You must set BUILDTYPE. Valid args are prod and literally anything else." >&2
  echo "When set to prod, the container base url is playtechnique.io. When set to anything else the base url is" >&2
  echo "localhost:8080, so that you can navigate URLs correctly on your laptop in dev mode." >&2
  exit 1
fi


if [[ "${BUILDTYPE}" = "prod" ]]; then
  BASEURL="playtechnique.io"
else # dev mode
  BASEURL="http://localhost"
fi

echo $BASEURL

docker build . -t playtechnique/bloggo_not_doggo:latest \
       --build-arg appendport="${APPENDPORT}" \
       --build-arg baseurl="${BASEURL}" \
       --build-arg port="${PORT}"

echo "playtechnique/bloggo_not_doggo:latest"
