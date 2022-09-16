#!/usr/bin/env bash

mkdir -p kustomize/resources || true

helm repo add elastic https://helm.elastic.co
helm repo update
helm template elastic-operator elastic/eck-operator -n operator-elasticsearch --create-namespace \
  --set podMonitor.enabled=true \
  --set config.metricsPort=8080 \
  > kustomize/resources/all-in-one.yaml

echo "Update manifests based on https://github.com/elastic/cloud-on-k8s/tree/main/config"