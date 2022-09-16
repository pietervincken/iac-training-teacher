#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    jq '.tag_name' --raw-output
}

## Change images
OPERATOR_VERSION=$(get_latest_release "jaegertracing/jaeger-operator") 
echo $OPERATOR_VERSION
curl -Ls https://github.com/jaegertracing/jaeger-operator/releases/download/$OPERATOR_VERSION/jaeger-operator.yaml \
  | yq -s '"kustomize/resources/" + .kind + "-" + .metadata.name + ".yml"' --no-doc

echo "Upgrade done."