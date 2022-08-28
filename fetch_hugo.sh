#!/bin/bash -el

HUGO_VERSION=0.102.0

function cleanup {
  rm hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
}

#trap cleanup EXIT

curl --silent -LO https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_Linux-64bit.tar.gz
LOCAL_SHASUM="$(shasum -a 256 hugo_${HUGO_VERSION}_Linux-64bit.tar.gz | awk '{ print $1 }')"

# The hugo releases github page file listings has a checksums.txt file.
UPSTREAM_SHASUM='91637c3f96cebaebc9356443a17ba44ab70ff4d570f1a5e48d08ccfca6bef2ef'

set -x
if [[ "${LOCAL_SHASUM}" != "${UPSTREAM_SHASUM}" ]]; then
  echo "hugo tarball SHASUM does not match reference" >&2
  exit 1
fi

mkdir hugo_files || true

tar -xzf hugo_${HUGO_VERSION}_Linux-64bit.tar.gz -C hugo_files/
