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

kubectl delete -k exercise-files

kubectl delete -k k8s/logging/eck-instance/kustomize
kubectl delete -k k8s/monitoring/prometheus-instance/kustomize
kubectl delete -k k8s/monitoring/grafana-instance/kustomize
kubectl delete -k k8s/tracing/jaeger-instance/kustomize 

kubectl delete -k k8s/tracing/jaeger-operator/kustomize
kubectl delete -k k8s/tracing/certmanager
kubectl delete -k k8s/logging/eck-operator/kustomize
kubectl delete -k k8s/monitoring/grafana-operator/kustomize
kubectl delete -k k8s/monitoring/prometheus-operator/kustomize
