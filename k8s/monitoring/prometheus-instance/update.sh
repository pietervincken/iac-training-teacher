#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

mkdir -p kustomize/resources/kube-state-metrics/ || true
mkdir -p kustomize/resources/blackbox-exporter/ || true
mkdir -p kustomize/resources/kubernetes/ || true
mkdir -p kustomize/resources/node-exporter/ || true
mkdir -p kustomize/resources/prometheus/ || true
mkdir -p kustomize/resources/alertmanager/ || true

### Update CRDs
git clone --depth=1 https://github.com/prometheus-operator/kube-prometheus.git
cp kube-prometheus/manifests/kube-state-metrics-* kustomize/resources/kube-state-metrics/
cp kube-prometheus/manifests/blackbox-exporter-* kustomize/resources/blackbox-exporter/
cp kube-prometheus/manifests/kubernetes-* kustomize/resources/kubernetes/
cp kube-prometheus/manifests/node-exporter-* kustomize/resources/node-exporter/
cp kube-prometheus/manifests/prometheus-[c-s]* kustomize/resources/prometheus/
cp kube-prometheus/manifests/alertmanager-* kustomize/resources/alertmanager/

#### Update images

rm -rf kube-prometheus

## Change images
# rm images.list
# grep -h image: kustomize/resources/*/*.yaml |sed 's/.*image: \(.*\)/\1/'|uniq >> images.list
# echo "traefik:v2.2.7" >> images.list

# PROMETHEUS_VERSION=$(grep -h image: kustomize/resources/prometheus/prometheus-prometheus.yaml |sed 's/.*image: .*:\(.*\)/\1/')
# sed -i.bak "s/prometheus:.*/prometheus:${PROMETHEUS_VERSION}/" kustomize/patches/prometheus-image.yaml
# rm kustomize/patches/prometheus-image.yaml.bak

# ALERTMANAGER_VERSION=$(grep -h image: kustomize/resources/alertmanager/alertmanager-alertmanager.yaml |sed 's/.*image: .*:\(.*\)/\1/')
# sed -i.bak "s/alertmanager:.*/alertmanager:${ALERTMANAGER_VERSION}/" kustomize/patches/alertmanager-image.yaml
# rm kustomize/patches/alertmanager-image.yaml.bak

# ## Upgrade Thanos
# THANOS_VERSION=$(get_latest_release "thanos-io/thanos")
# sed -i.bak "s/version:.*/version: $THANOS_VERSION/" ./kustomize/patches/prometheus.yaml
# sed -i.bak "s/newTag:.*/newTag: $THANOS_VERSION/" ./kustomize/resources/thanos/kustomization.yaml
# sed -i.bak "s/app.kubernetes.io\/version:.*/app.kubernetes.io\/version: $THANOS_VERSION/" ./kustomize/resources/thanos/resources/query-service.yaml
# sed -i.bak "s/app.kubernetes.io\/version:.*/app.kubernetes.io\/version: $THANOS_VERSION/" ./kustomize/resources/thanos/resources/query-serviceMonitor.yaml
# sed -i.bak "s/app.kubernetes.io\/version:.*/app.kubernetes.io\/version: $THANOS_VERSION/" ./kustomize/resources/thanos/resources/query-deployment.yaml
# sed -i.bak "s/app.kubernetes.io\/version:.*/app.kubernetes.io\/version: $THANOS_VERSION/" ./kustomize/resources/thanos/resources/compactor-statefulSet.yaml
# sed -i.bak "s/app.kubernetes.io\/version:.*/app.kubernetes.io\/version: $THANOS_VERSION/" ./kustomize/resources/thanos/resources/store-statefulSet.yaml
# rm kustomize/patches/prometheus.yaml.bak
# rm kustomize/resources/thanos/kustomization.yaml.bak
# rm kustomize/resources/thanos/resources/query-deployment.yaml.bak
# rm kustomize/resources/thanos/resources/query-service.yaml.bak
# rm kustomize/resources/thanos/resources/query-serviceMonitor.yaml.bak
# rm kustomize/resources/thanos/resources/compactor-statefulSet.yaml.bak
# rm kustomize/resources/thanos/resources/store-statefulSet.yaml.bak

# echo "quay.io/thanos/thanos:${THANOS_VERSION}" >> images.list

echo "Upgrade done. Please check kustomize/resources/kubernetes/kubernetes-prometheusRule.yaml!"