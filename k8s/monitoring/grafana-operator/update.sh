#!/bin/bash

mkdir kustomize || true

#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    jq '.tag_name' --raw-output
}

VERSION=$(get_latest_release "grafana-operator/grafana-operator")

GRAFANA_VERSION=$(get_latest_release "grafana/grafana" | sed 's/v//')

echo operator: $VERSION
echo grafana: $GRAFANA_VERSION

git clone --depth 1 --branch $VERSION https://github.com/grafana-operator/grafana-operator.git 2> /dev/null

cp -R grafana-operator/config kustomize/

yq -i ".[].value |= \"$GRAFANA_VERSION\"" kustomize/patches/grafana-image-version.yaml

rm -rf grafana-operator