---
title: "Investigating the Codebase"
date: 2022-11-07T08:05:33-07:00
draft: false
---




So, I should get familiar with the codebase. Step 1 seems to me to be running the tests.

My first issue was that the Makefile was downloading the linux version of shellcheck. You can see my patch [here](https://github.com/actions-runner-controller/actions-runner-controller/commit/9eae9ac75f95cf88e263c1d1517dcb243a0acda2)

The tests still don't work. The error message is about not being able to find the etcd binary.
![image screenshot of a conversation with a friend. It says, "I just want to get actions-runner-controller's test suite working \
It's failing on my laptop inside an upstream kubernetes test. There's this big ol' header comment \
BinPathFinder finds the path to the given named binary, using the following locations \
in order of precedence (highest first). Notice that the various env vars only need \
I to be set -- the asset is not checked for existence on the filesystem. \
TEST_ASSET_{tr/a-z-/A-Z_I (if set; asset overrides -- EnvAssetOverridePrefix) \
KUBEBUILDER_ASSETS (if set; global asset path -- EnvAssetsPath) \
assetDirectory (if set; per-config asset directory) \
/usr/local/kubebuilder/bin (AssetsDefaultPath).\
](/whats-my-interest-in-actions-runner-controller/test-investigation.png)
