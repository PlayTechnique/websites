#!/bin/bash -el

THIS_SCRIPT_DIR=$(cd $(dirname $0) && pwd)
cd "${THIS_SCRIPT_DIR}"

ansible-playbook -i inventory.yaml -l droplets playbook.yaml
