#!/bin/bash
set -e

cd exercise-1-solution
terraform init
terraform destroy -auto-approve
cd ..