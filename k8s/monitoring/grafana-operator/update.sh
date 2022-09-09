#!/bin/bash

mkdir kustomize || true

git clone --depth 1 https://github.com/grafana-operator/grafana-operator.git

cp -R grafana-operator/config kustomize/

rm -rf grafana-operator