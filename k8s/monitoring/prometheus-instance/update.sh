#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    jq '.tag_name' --raw-output
}

mkdir -p kustomize/resources/kube-state-metrics/ || true
mkdir -p kustomize/resources/blackbox-exporter/ || true
mkdir -p kustomize/resources/kubernetes/ || true
mkdir -p kustomize/resources/node-exporter/ || true
mkdir -p kustomize/resources/prometheus/ || true
mkdir -p kustomize/resources/alertmanager/ || true

VERSION=$(get_latest_release "prometheus-operator/kube-prometheus")

### Update CRDs
git clone --depth 1 --branch $VERSION https://github.com/prometheus-operator/kube-prometheus.git 2> /dev/null
cp kube-prometheus/manifests/kubeStateMetrics* kustomize/resources/kube-state-metrics/
cp kube-prometheus/manifests/blackboxExporter-* kustomize/resources/blackbox-exporter/
cp kube-prometheus/manifests/kubernetesControlPlane-* kustomize/resources/kubernetes/
cp kube-prometheus/manifests/nodeExporter-* kustomize/resources/node-exporter/
cp kube-prometheus/manifests/prometheus-* kustomize/resources/prometheus/
cp kube-prometheus/manifests/alertmanager-* kustomize/resources/alertmanager/

#### Update images

rm -rf kube-prometheus

# ## Upgrade Thanos
# THANOS_VERSION=$(get_latest_release "thanos-io/thanos")