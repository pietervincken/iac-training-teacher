#!/usr/bin/env bash

export VERSION=v0.48.1

mkdir -p kustomize/resources || true
mkdir -p kustomize/resources/crds || true

### Update CRDs
git clone --depth=1 https://github.com/prometheus-operator/prometheus-operator
cp prometheus-operator/example/prometheus-operator-crd/* kustomize/resources/crds/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-deployment.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-account.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-monitor.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role-binding.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator-crd/prometheus-operator-crd-cluster-roles.yaml kustomize/resources/

rm -rf prometheus-operator
