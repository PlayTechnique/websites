#!/bin/bash -el

THIS_SCRIPT_DIR="$(cd $(dirname $0) && pwd)"
cd $THIS_SCRIPT_DIR

docker build . -t playtechnique/bloggo_not_doggo:latest
echo "playtechnique/bloggo_not_doggo:latest"
