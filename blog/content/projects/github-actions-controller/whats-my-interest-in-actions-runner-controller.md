---
title: "What's My Interest In Actions Runner Controller?"
date: 2022-11-04T08:01:09-06:00
draft: false
---

At work, I got to using this pretty neat Kubernetes controller, [actions runner controller](https://github.com/actions-runner-controller/actions-runner-controller).

It lets you host [self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners#about-self-hosted-runners)
as kubernetes pods, so they are removed after a build run and your build runners don't maintain state. Neat!

Currently, you either register the runners at the Enterprise, Organisation, or an individual user's repository level. These look like they're restrictions from the
github api; I don't see a mention anywhere that I can register runners to run entirely in an individual's namespace.

I want to add a feature that allows me to register multiple repositories inside a user's namespace. I currently envision this as a list handed in to the runner register.
The current registration for users requires writing this file (taken from [the docs](https://github.com/actions-runner-controller/actions-runner-controller/blob/master/docs/detailed-docs.md#repository-runners) ):

```yaml
# runnerdeployment.yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: example-runnerdeploy
spec:
  replicas: 1
  template:
    spec:
      repository: mumoshu/actions-runner-controller-ci
```
I'd like to be able to parse this file:


```yaml
```yaml
# runnerdeployment.yaml
apiVersion: actions.summerwind.dev/v1alpha1
kind: RunnerDeployment
metadata:
  name: example-runnerdeploy
spec:
  replicas: 1
  template:
    spec:
      repositories: 
        - gwynforthewyn/actions-runner-controller-ci
        - gwynforthewyn/jinkies
```

Each runner container will start up with a unique callback repository.

I think this involves updating the controller so that it can take a list, and then understands that each list is a config element that's uniquely spawned inside each container.