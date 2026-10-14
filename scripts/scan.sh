#!/usr/bin/env bash
set -euo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "Gitleaks is not installed. Install it before running this script."
  exit 1
fi

if ! command -v trivy >/dev/null 2>&1; then
  echo "Trivy is not installed. Install it before running this script."
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform is not installed. Install it before running this script."
  exit 1
fi

echo "Running secret detection with Gitleaks..."
gitleaks detect --source . --no-banner --exit-code 1

echo "Building Docker image..."
docker build -t devsecops-demo:latest .

echo "Scanning Docker image with Trivy..."
trivy image --severity HIGH,CRITICAL devsecops-demo:latest

echo "Initializing Terraform..."
terraform -chdir=terraform init

echo "Validating Terraform configuration..."
terraform -chdir=terraform validate

echo "Planning Terraform deployment..."
terraform -chdir=terraform plan -out=tfplan

echo "Pipeline validation succeeded."
