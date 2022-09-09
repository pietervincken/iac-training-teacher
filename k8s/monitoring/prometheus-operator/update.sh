#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    jq '.tag_name' --raw-output
}

VERSION=$(get_latest_release "prometheus-operator/prometheus-operator")

echo $VERSION

### Update CRDs
git clone --depth 1 --branch $VERSION https://github.com/prometheus-operator/prometheus-operator 2> /dev/null
cp prometheus-operator/example/prometheus-operator-crd/* kustomize/resources/crds/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-deployment.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-account.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-service-monitor.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator/prometheus-operator-cluster-role-binding.yaml kustomize/resources/
cp prometheus-operator/example/rbac/prometheus-operator-crd/prometheus-operator-crd-cluster-roles.yaml kustomize/resources/

rm -rf prometheus-operator *.bak