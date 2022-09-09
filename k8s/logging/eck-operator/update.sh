#!/usr/bin/env bash

mkdir -p kustomize/resources || true

helm repo add elastic https://helm.elastic.co
helm repo update
helm template elastic-operator elastic/eck-operator -n operator-elasticsearch --create-namespace \
  --set podMonitor.enabled=true \
  --set config.metricsPort=8080 \
  > kustomize/resources/all-in-one.yaml

#### Update images
# VERSION=$(grep app.kubernetes.io/version kustomize/resources/all-in-one.yaml  |head -1|sed 's/.[^"]*"\([^"]*\)"/\1/')
# sed -i.bak s/"docker.elastic.co\/eck\/eck-operator:[^-]*"/"docker.elastic.co\/eck\/eck-operator:${VERSION}"/ images.list
# rm images.list.bak