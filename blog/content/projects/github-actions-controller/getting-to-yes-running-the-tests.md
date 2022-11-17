---
title: "Getting to Yes: Running the Tests"
date: 2022-11-12T11:15:54-07:00
draft: false
---

I'm still struggling getting these tests running. I decided I want to get the command `make test with deps` executing, as
a narrow scope of work.

The tests try to start a local test k8s cluster, I think using kind, along with etcd. 

When I run it, I see this at the top of the tests:
```bash
; make test-with-deps                                                                                                                                                                                                                                          
# See https://pkg.go.dev/sigs.k8s.io/controller-runtime/pkg/envtest#pkg-constants
TEST_ASSET_KUBE_APISERVER=/Users/gwyn/Developer/actions-runner-controller/test-assets/kube-apiserver \
	TEST_ASSET_ETCD=/Users/gwyn/Developer/actions-runner-controller/test-assets/etcd \
	TEST_ASSET_KUBECTL=/usr/local/bin/kubectl \
	 make test
```
The test failure says:

```bash
  Unexpected error:
      <*fmt.wrapError | 0xc0004f4360>: {
          msg: "unable to start control plane itself: failed to start the controlplane. retried 5 times: timeout waiting for process etcd to start successfully (it may have failed to start, or stopped unexpectedly before becoming ready)",
      }
      unable to start control plane itself: failed to start the controlplane. retried 5 times: timeout waiting for process etcd to start successfully (it may have failed to start, or stopped unexpectedly before becoming ready)
  occurred

  /Users/gwyn/Developer/actions-runner-controller/controllers/suite_test.go:75
------------------------------
```

This isn't super clear about the cause of the error. If I go check line 75 of suit_test, it reads:

```go
74:	cfg, err = testEnv.Start()
75:	Expect(err).ToNot(HaveOccurred())
```

So the error's in testEnv.Start()

What does make test-with-deps do?

```make
# Run tests
test: generate fmt vet manifests shellcheck
	go test $(GO_TEST_ARGS) ./... -coverprofile cover.out
	go test -fuzz=Fuzz -fuzztime=10s -run=Fuzz* ./controllers

test-with-deps: kube-apiserver etcd kubectl
	# See https://pkg.go.dev/sigs.k8s.io/controller-runtime/pkg/envtest#pkg-constants
	TEST_ASSET_KUBE_APISERVER=$(KUBE_APISERVER_BIN) \
	TEST_ASSET_ETCD=$(ETCD_BIN) \
	TEST_ASSET_KUBECTL=$(KUBECTL_BIN) \
	  make test
```

I tinkered in goland for a _while_ trying to figure out what was possibly going wrong; my test-assets directory was correctly populated,
but I just couldn't get etcd started. Eventually, I just invoked the etcd binary and got a stack trace out of it:

```bash
; ./etcd                                                                                                                                                                                                        Developer/actions-runner-controller/test-assets
fatal error: runtime: bsdthread_register error

runtime stack:
runtime.throw(0x1bed3fa, 0x21)
	/usr/local/go/src/runtime/panic.go:616 +0x81 fp=0x7ff7bfeff588 sp=0x7ff7bfeff568 pc=0x102a871
runtime.goenvs()
	/usr/local/go/src/runtime/os_darwin.go:129 +0x83 fp=0x7ff7bfeff5b8 sp=0x7ff7bfeff588 pc=0x10283f3
runtime.schedinit()
	/usr/local/go/src/runtime/proc.go:501 +0xd6 fp=0x7ff7bfeff620 sp=0x7ff7bfeff5b8 pc=0x102d166
runtime.rt0_go(0x7ff7bfeff650, 0x1, 0x7ff7bfeff650, 0x1000000, 0x1, 0x7ff7bfeff818, 0x0, 0x7ff7bfeff81f, 0x7ff7bfeff829, 0x7ff7bfeff83f, ...)
	/usr/local/go/src/runtime/asm_amd64.s:252 +0x1f4 fp=0x7ff7bfeff628 sp=0x7ff7bfeff620 pc=0x1056474
```

That'll do it!

So to run these tests I need a version of etcd that works on macOS.

The modern day kubebuilder project is confusingly laid out to my brain, but I figured out that [they are downloading etcd from coreos]
(https://github.com/kubernetes-sigs/kubebuilder/blob/d63a7cd30ae3e36b01e6264b63ff19083add8961/build/thirdparty/darwin/Dockerfile#L52),
so I updated the makefile to do the same thing and submitted a patch at https://github.com/actions-runner-controller/actions-runner-controller/pull/2013/files

This is bigger than my previous PR, and I'm not following the requested process from CONTRIBUTING.md, so let's see if there's
pushback.
