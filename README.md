# Flux2 Infra repository

This repository contains infrastructure applications and addons that can be installed inside Kubernetes with FluxCD.

# Table of Contents

- [Support Project](#support-project)
- [Prerequisites](#prerequisites)
- [List of applications](#list-of-applications)
- [Import current repository](#import-current-repository)
  - [Substitute variables](#substitute-variables)
- [Repository structure](#repository-structure)
- [Structure idea](#structure-idea)
- [Flex/Stable Bundles and promotion](#flexstable-bundles-and-promotion)
- [Slack Notifications](#slack-notifications)

## Support Project
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/N4N011QV6F)

## Prerequisites

- Kubernetes cluster version 1.24 or newer
- Flux version 2.3.0 or newer bootstrapped to the [Head repository (example)](https://github.com/brainfair/awesome-flux-head)
- [CRD GitOps repository](https://github.com/brainfair/awesome-flux-crds) must be included before this as a dependency.

## List of applications
### Core Components
- [aws-load-balancer-controller](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/aws-load-balancer-controller)
- [cert-manager](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/cert-manager)
- [cluster-autoscaler](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/cluster-autoscaler)
- [external-dns](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/external-dns)
- [external-secrets](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/external-secrets)
- [Istio ServiceMesh](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/istio)
### Observability Components
- [Victoria Metrics (victoria-metrics-k8s-stack)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/victoria-metrics-k8s-stack) - Metrics Database
- [Victoria Logs Single](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/victoria-logs) - Logs Database
- [flux-monitoring](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/flux-monitoring) - alerts and dashboards for the FluxCD
- [Loki](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/loki)
- [Grafana Alloy](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/alloy)
- [blackbox-exporter](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/blackbox-exporter)
- [helm-exporter](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/helm-exporter)
- [k8s-event-logger](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/k8s-event-logger)
- [kubelinks](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/kubelinks)
- [metrics-server](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/metrics-server)
- [oomkill-exporter](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/oomkill-exporter)
- [x509-certificate-exporter](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/x509-certificate-exporter)
### Nice to have
- [reflector](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/reflector)
- [KEDA](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/keda)
- [stakater/Reloader](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/reloader)
### Extra Components
- [Apache Airflow](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/airflow)
- [ArgoCD](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/argocd)
- [cloudnative-pg (PostgreSQL operator)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/cloudnative-pg)
- [cloudnative-pg tenant example](https://github.com/brainfair/awesome-flux-infra/tree/main/clusters/homelab/pg-airflow)
- [pgadmin](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/pgadmin)
- [Dragonfly Operator (redis replacement)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/dragonfly-operator)
- [Dragonfly Instance (redis replacement)](https://github.com/brainfair/awesome-flux-infra/tree/main/clusters/homelab/redis)
- [Clickhouse Operator (Altinity)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/clickhouse-operator)
- [Clickhouse simple example (Altinity)](https://github.com/brainfair/awesome-flux-infra/tree/main/clusters/homelab/clickhouse)
- [Jenkins](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/jenkins-server)
- [kro (Kube Resource Orchestrator)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/kro)
- [Strimzi Kafka Operator](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/strimzi)
- [capacitor (Flux UI)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/capacitor)
- [ollama & open-webui](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/ollama)
- [minio-operator](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/minio-operator)
- [minio-tenant example](https://github.com/brainfair/awesome-flux-infra/tree/main/clusters/homelab/minio-loki)
- [SeaweedFS (S3 alternative)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/seaweedfs)
- [elastic operator (ECK)](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/eck-operator)
- [httpbin](https://github.com/brainfair/awesome-flux-infra/tree/main/apps/base/httpbin)

## Import current repository

Create GitRepository and Flux Kustomization in your main repository (change path and substitute variables as needed):

```yaml
---
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: fluxcd-gitops-infra
  namespace: flux-system
spec:
  interval: 10m
  ref:
    branch: main
  secretRef:
    name: flux-system
  url: https://github.com/brainfair/awesome-flux-infra.git
  ignore: |
 # exclude README.md
 /README.md
---
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: fluxcd-gitops-infra
  namespace: flux-system
spec:
  dependsOn:
 - name: fluxcd-gitops-crds
  interval: 10m
  path: ./clusters/homelab
  prune: true
  sourceRef:
    kind: GitRepository
    name: fluxcd-gitops-infra
  postBuild:
    substitute:
      env: "homelab"
      cluster_name: "docker-desktop"
      cluster_subdomain: "localhost.direct"
```

### Substitute variables

* env - environment name
* cluster_name - the name of the Kubernetes cluster
* cluster_subdomain - subdomain for all ingress resources

[Check head repository example](https://github.com/brainfair/awesome-flux-head/blob/main/clusters/homelab/01-infra.yaml)

## Repository structure

The Git repository contains the following top directories:

- **apps/base** dir contains base application objects such as helmrelease, helmrepository, namespace, etc...
- **apps/bundles** dir contains bundles for different types of environment
- **clusters** dir contains cluster entry point where we can include different bundles or custom apps

```
── apps
 ├── base
 ├   ├── aws-load-balancer-controller
 ├   ├── blackbox-exporter
 ├   ....
 ├── bundles
    ├── eks-flex
    ├── eks-stable
    ├── aks-flex
    ├── aks-stable
    ├── esxi-flex
    ├── esxi-stable
    ├── docker-flex
    ├── docker-stable
    ├── ...
── clusters
    ├── eks-cluster
    ├── aks-cluster
    ├── dockerdesktop-cluster
    ├── vmware-cluster
    ├── ...
```

## Structure idea

The basic idea to define 3 levels of application kustomization:
* base level inside apps/base defines a common definition of application and values for everything
* bundles level inside apps/bundles defines aggregation of the base application and kustomization for the specified bundle
* cluster level inside clusters/[cluster_name] defines entry point where we can include some bundle and override cluster-specific values or add something more

![Structure](flex-stable.drawio.svg)

## Flex/Stable Bundles and promotion

To keep infrastructure up-to-date we defined two bundles for the Docker Desktop environment.
* docker-flex - where we define the version range for every application (block major updates) for automatic updates
* docker-stable - where we define a pinned version for each application.

Non-production environment should include a flex bundle where we can play/test/evaluate new applications and new versions.
Production environments should be a pointer to a stable bundle.

For 3rd party applications when a new version is successfully updated in the flex bundle we run the [promotion workflow](https://github.com/brainfair/awesome-flux-infra/blob/main/.github/workflows/promotion.yml) triggered by [dispatch notification](https://github.com/brainfair/awesome-flux-infra/blob/main/clusters/homelab/flux-promotion/gh-dispatch.yaml) defined in the staging docker cluster.

![Promotion Diagram](fluxcd-promote.drawio.svg)
