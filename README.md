# iac-training-teacher

## .env

A dot-env file is required for this demo to run. Fill it with the following contents: 

``` bash
export location="westeurope" # Location to be used by the demo. Terraform resources might get created outside of this!
export rgstate="rg-xxx" # Name of the resource group to be created for the storage account below
export sastate="saxxx" # Storage account name to be created to hold the terraform state for this demo
export subscription="xxx-xxx-xxx-xxx-xxx" # Subscription ID where this demo needs to be deployed
export tenant="xxx-xxx-xxx-xxx-xxx" # Tenant ID used for this demo (needed for some TF configuration)
export ARM_TENANT_ID=$tenant # This is needed to pass the tenant ID to the Terraform setup. 
```

## Walkthrough

- Slides: Intro into declarative configuration
- Slides: Intro into Infra as code
- Slides: Intro into Terraform
- Hands-on: Deploy AKS into resource group
- Hands-on: Create Terraform module
- Slides: Remote state
- Hands-on: Remote state
- Lunch
- Slides: Monitoring intro: Metrics
- Slides: Prometheus, Grafana, Azure monitoring
- Hands-on: Prometheus queries + Grafana
- Slides: Logging solutions
- Hands-on: Kibana logs searching
- Slides: Debugging cloud applications
- Hands-on: Find the issues

## links
- https://ordina-jworks.github.io/monitoring/2020/11/16/monitoring-spring-prometheus-grafana.html
- https://micrometer.io/docs/registry/prometheus

## TODO 

- ECK / Logging
- Tracing