#!/bin/bash -el

# Run this script to build the container which contains the blog output
THIS_SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BLOG_DIR="../blog.playtechnique.io"

# Directory containing blog html files
BLOG_OUTPUT_DIR="${BLOG_DIR}/output"

# Used to copy the html content from the pelican build to somewhere that docker
# can see the files and directories
PUBLIC_HTML_DIR="${THIS_SCRIPT_DIR}/public-html"

cd "${THIS_SCRIPT_DIR}"
source ../venv/bin/activate
source build.env

function clean_up {
    cd "${BLOG_DIR}"
    make clean > /dev/null 2>&1
    rm -rf ${BLOG_OUTPUT_DIR} > /dev/null 2>&1
    rm -rf ${PUBLIC_HTML_DIR} > /dev/null 2>&1
    cd -
}

trap clean_up EXIT
clean_up

cd "${BLOG_DIR}"
make html

# The html content needs to be inside the Docker folder for
# the docker tooling to see it.
cd "${THIS_SCRIPT_DIR}"

mkdir "${PUBLIC_HTML_DIR}"
cp -R "${BLOG_OUTPUT_DIR}/" "${PUBLIC_HTML_DIR}/"

docker build . -t ${IMAGE_TAG}:${IMAGE_VERSION}
