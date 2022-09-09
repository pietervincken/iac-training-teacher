#!/bin/bash

rgruntime=$(cat tf/output.json| jq --raw-output '.rg_runtime.value')

if [ -z $rgruntime ]; then
    echo "Could not find rgruntime. Stopping!"
    exit 1
fi

clustername=$(cat tf/output.json| jq --raw-output '.cluster_name.value')

if [ -z $clustername ]; then
    echo "Could not find clustername. Stopping!"
    exit 1
fi

az aks get-credentials -g $rgruntime -n $clustername --admin --overwrite-existing

# kubectl apply -k k8s/microservice-demo/kustomize

# kubectl apply -k k8s/hello-kubernetes-demo