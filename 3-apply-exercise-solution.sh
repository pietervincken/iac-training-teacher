#!/bin/bash
set -e

cd exercise-1-solution
terraform init
terraform apply
terraform output pg_user
terraform output pg_password
cd ..