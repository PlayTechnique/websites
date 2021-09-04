#!/bin/bash -el

# Run this script to build the container which contains the blog output
DOCKERFILE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo ${DOCKERFILE_DIR}

# Used to copy the html content from the pelican build to somewhere that docker
# can see the files and directories
OUTPUT_DIR="${DOCKERFILE_DIR}/output"
echo ${OUTPUT_DIR}

cd "${DOCKERFILE_DIR}"
source ../venv/bin/activate
source build.env

function clean_up {
    cd "${BLOG_DIR}"
    make clean
    rm -rf ${OUTPUT_DIR}
}

trap clean_up EXIT

cd "${BLOG_DIR}"
make html

# The html content needs to be inside the Docker folder for
# the docker tooling to see it.
cd "${DOCKERFILE_DIR}"

mkdir "${OUTPUT_DIR}"
cp -R "${BLOG_PELICAN_OUTPUT_DIR}/" "${OUTPUT_DIR}"

docker build . -t ${IMAGE_TAG}:${IMAGE_VERSION}
