#!/bin/bash

set -e pipefail

rgruntime=$(cat tf/output.json| jq --raw-output '.rg_runtime.value')
edClientId=$(cat tf/output.json| jq --raw-output '.external_dns_client_id.value')
edResourceId=$(cat tf/output.json| jq --raw-output '.external_dns_resource_id.value')
clustername=$(cat tf/output.json| jq --raw-output '.cluster_name.value')

if [ -z $edResourceId ]; then
    echo "Could not find edResourceId. Stopping!"
    exit 1
fi

if [ -z $edClientId ]; then
    echo "Could not find edClientId. Stopping!"
    exit 1
fi

if [ -z $rgruntime ]; then
    echo "Could not find rgruntime. Stopping!"
    exit 1
fi

if [ -z $clustername ]; then
    echo "Could not find clustername. Stopping!"
    exit 1
fi

cat <<EOF > k8s/secrets/azure.json
{
    "tenantId": "$tenant",
    "subscriptionId": "$subscription",
    "resourceGroup": "rg-jworksyppiac",
    "useManagedIdentityExtension": true,
    "userAssignedIdentityID": "$edClientId"
}
EOF

yq -i ".[0].value |= \"$edResourceId\"" k8s/patches/azureidentity.yaml 
yq -i ".[1].value |= \"$edClientId\"" k8s/patches/azureidentity.yaml 

az aks get-credentials -g $rgruntime -n $clustername --admin --overwrite-existing

kubectl apply -k k8s --server-side || kubectl apply -k k8s --server-side || true # hack to apply twice if first fails (expected)

kubectl apply -k exercise-files