#!/usr/bin/env bash

### Helper
get_latest_release() {
  curl --silent "https://api.github.com/repos/$1/releases/latest" | # Get latest release from GitHub api
    grep '"tag_name":' |                                            # Get tag line
    sed -E 's/.*"([^"]+)".*/\1/'                                    # Pluck JSON value
}

mkdir -p kustomize/resources || true

cd kustomize/resources
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing.io_jaegers_crd.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role.yaml
curl -O https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role_binding.yaml
cd ../..

# ## Change images
# OPERATOR_VERSION=$(get_latest_release "jaegertracing/jaeger-operator" |sed "s/v//") 

# ## yaml files are sometimes too new:
# sed -i.bak  "s/newTag: .*/newTag: $OPERATOR_VERSION/" kustomize/kustomization.yaml
# rm kustomize/kustomization.yaml.bak

echo "Upgrade done."