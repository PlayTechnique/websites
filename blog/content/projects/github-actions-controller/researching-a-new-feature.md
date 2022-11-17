---
title: "Researching a New Feature"
date: 2022-11-17T07:17:49-07:00
draft: false
---

Desired new feature: have one installation of the controller serve multiple user repositories.

Starting inside the runner image, it's defined in actions-runner-controller. Its [entrypoint script](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/runner/entrypoint.sh)
executes startup.sh pretty quickly.

Startup.sh looks like it concatenates 2 env vars to register its callback into github:

```bash

 
Pull requests
Issues
Codespaces
Marketplace
Explore
 
@gwynforthewyn 
actions-runner-controller
/
actions-runner-controller
Public
Edit Pins 
 Watch 31 
Fork 592
 Star 2.4k
Code
Issues
87
Pull requests
15
Discussions
Actions
Projects
Security
Insights
 master 
actions-runner-controller/runner/startup.sh
Go to file

@mumoshu
mumoshu Fix runners to do their best to gracefully stop on pod eviction (#1759)
…

Latest commit c74ad61 16 days ago
 History
 7 contributors
@mumoshu @toast-gear @Fleshgrinder @Vladyslav-Miletskyi @rofafor @Hi-Fi @bkimbrough88
 Executable File  172 lines (147 sloc)  5.95 KB
Raw Blame

 
#!/bin/bash
source logger.sh

RUNNER_ASSETS_DIR=${RUNNER_ASSETS_DIR:-/runnertmp}
RUNNER_HOME=${RUNNER_HOME:-/runner}

# Let GitHub runner execute these hooks. These environment variables are used by GitHub's Runner as described here
# https://github.com/actions/runner/blob/main/docs/adrs/1751-runner-job-hooks.md
# Scripts referenced in the ACTIONS_RUNNER_HOOK_ environment variables must end in .sh or .ps1
# for it to become a valid hook script, otherwise GitHub will fail to run the hook
export ACTIONS_RUNNER_HOOK_JOB_STARTED=/etc/arc/hooks/job-started.sh
export ACTIONS_RUNNER_HOOK_JOB_COMPLETED=/etc/arc/hooks/job-completed.sh

if [ -n "${STARTUP_DELAY_IN_SECONDS}" ]; then
  log.notice "Delaying startup by ${STARTUP_DELAY_IN_SECONDS} seconds"
  sleep "${STARTUP_DELAY_IN_SECONDS}"
fi

if [ -z "${GITHUB_URL}" ]; then
  log.debug 'Working with public GitHub'
  GITHUB_URL="https://github.com/"
else
  length=${#GITHUB_URL}
  last_char=${GITHUB_URL:length-1:1}

  [[ $last_char != "/" ]] && GITHUB_URL="$GITHUB_URL/"; :
  log.debug "Github endpoint URL ${GITHUB_URL}"
fi

if [ -z "${RUNNER_NAME}" ]; then
  log.error 'RUNNER_NAME must be set'
  exit 1
fi

if [ -n "${RUNNER_ORG}" ] && [ -n "${RUNNER_REPO}" ] && [ -n "${RUNNER_ENTERPRISE}" ]; then
  ATTACH="${RUNNER_ORG}/${RUNNER_REPO}"
elif [ -n "${RUNNER_ORG}" ]; then
  ATTACH="${RUNNER_ORG}"
elif [ -n "${RUNNER_REPO}" ]; then
  ATTACH="${RUNNER_REPO}"
elif [ -n "${RUNNER_ENTERPRISE}" ]; then
  ATTACH="enterprises/${RUNNER_ENTERPRISE}"
else
  log.error 'At least one of RUNNER_ORG, RUNNER_REPO, or RUNNER_ENTERPRISE must be set'
  exit 1
fi

if [ -z "${RUNNER_TOKEN}" ]; then
  log.error 'RUNNER_TOKEN must be set'
  exit 1
fi

if [ -z "${RUNNER_REPO}" ] && [ -n "${RUNNER_GROUP}" ];then
  RUNNER_GROUPS=${RUNNER_GROUP}
fi

# Hack due to https://github.com/actions-runner-controller/actions-runner-controller/issues/252#issuecomment-758338483
if [ ! -d "${RUNNER_HOME}" ]; then
  log.error "$RUNNER_HOME should be an emptyDir mount. Please fix the pod spec."
  exit 1
fi

# if this is not a testing environment
if [[ "${UNITTEST:-}" == '' ]]; then
  sudo chown -R runner:docker "$RUNNER_HOME"
  # enable dotglob so we can copy a ".env" file to load in env vars as part of the service startup if one is provided
  # loading a .env from the root of the service is part of the actions/runner logic
  shopt -s dotglob
  # use cp instead of mv to avoid issues when src and dst are on different devices
  cp -r "$RUNNER_ASSETS_DIR"/* "$RUNNER_HOME"/
  shopt -u dotglob
fi

if ! cd "${RUNNER_HOME}"; then
  log.error "Failed to cd into ${RUNNER_HOME}"
  exit 1
fi

# past that point, it's all relative pathes from /runner

config_args=()
if [ "${RUNNER_FEATURE_FLAG_ONCE:-}" != "true" ] && [ "${RUNNER_EPHEMERAL}" == "true" ]; then
  config_args+=(--ephemeral)
  log.debug 'Passing --ephemeral to config.sh to enable the ephemeral runner.'
fi
if [ "${DISABLE_RUNNER_UPDATE:-}" == "true" ]; then
  config_args+=(--disableupdate)
  log.debug 'Passing --disableupdate to config.sh to disable automatic runner updates.'
fi

update-status "Registering"

retries_left=10
while [[ ${retries_left} -gt 0 ]]; do
  log.debug 'Configuring the runner.'
  ./config.sh --unattended --replace \
    --name "${RUNNER_NAME}" \
    --url "${GITHUB_URL}${ATTACH}" \
    --token "${RUNNER_TOKEN}" \
    --runnergroup "${RUNNER_GROUPS}" \
    --labels "${RUNNER_LABELS}" \
    --work "${RUNNER_WORKDIR}" "${config_args[@]}"
```
from https://github.com/actions-runner-controller/actions-runner-controller/blob/8f374d561fa1a51079d1cf6c2acfaa2a1babc05a/runner/startup.sh#L94


GITHUB_URL is either the public github URL or a github enterprise server URL.
ATTACH is the key here. It's built from other variables, because it's always turtles all the way down:

```bash
if [ -n "${RUNNER_ORG}" ] && [ -n "${RUNNER_REPO}" ] && [ -n "${RUNNER_ENTERPRISE}" ]; then
  ATTACH="${RUNNER_ORG}/${RUNNER_REPO}"
elif [ -n "${RUNNER_ORG}" ]; then
  ATTACH="${RUNNER_ORG}"
elif [ -n "${RUNNER_REPO}" ]; then
  ATTACH="${RUNNER_REPO}"
elif [ -n "${RUNNER_ENTERPRISE}" ]; then
  ATTACH="enterprises/${RUNNER_ENTERPRISE}"
else
  log.error 'At least one of RUNNER_ORG, RUNNER_REPO, or RUNNER_ENTERPRISE must be set'
  exit 1
fi
```
from https://github.com/actions-runner-controller/actions-runner-controller/blob/master/runner/startup.sh#L35

RUNNER_ORG and RUNNER_REPO are handed in as values in the pod file definition.

# Hypothesis
If I can have 2 RUNNER_REPO entries in the pod definition, and have the controller recognise there are multiple repos
defined, then I can have the controller spin up 1 runner per RUNNER_REPO.
