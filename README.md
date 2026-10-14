# Azure DevSecOps Pipeline for Containerized App Deployment

This project is an Azure-focused version of the DevSecOps pipeline. It implements a secure CI/CD workflow that includes:
- Gitleaks for secret scanning
- Trivy for image and filesystem vulnerability detection
- Terraform for Azure infrastructure provisioning
- Jenkins or GitLab CI for automation
- Azure Container Registry (ACR) and Azure resource deployment

## Azure architecture

Developer pushes code -> Jenkins/GitLab CI -> Gitleaks scan -> Docker build -> Trivy scan -> Terraform plan/apply -> Azure Resource Group + ACR + Storage Account

## Repository structure

```text
.
├── app/
│   └── hello.py
├── scripts/
│   └── scan.sh
├── terraform/
│   ├── main.tf
│   ├── provider.tf
│   ├── variables.tf
│   └── outputs.tf
├── .gitignore
├── .gitleaks.toml
├── .trivyignore
├── .gitlab-ci.yml
├── Dockerfile
├── Jenkinsfile
├── README.md
└── LICENSE
```

## Prerequisites

Install:
- Docker
- Terraform >= 1.5
- Trivy
- Gitleaks
- Azure CLI

Authenticate with Azure:
```bash
az login
az account set --subscription "<your-subscription-id>"
```

Optional CI variables for Azure DevOps / GitLab / Jenkins:
- ARM_CLIENT_ID
- ARM_CLIENT_SECRET
- ARM_TENANT_ID
- ARM_SUBSCRIPTION_ID

## Local validation

Build the app image:
```bash
docker build -t devsecops-demo:latest .
```

Run secret detection:
```bash
gitleaks detect --source . --no-banner --exit-code 1
```

Run Trivy filesystem scan:
```bash
trivy fs .
```

Run Trivy image scan:
```bash
trivy image --severity HIGH,CRITICAL devsecops-demo:latest
```

Run Terraform validation:
```bash
terraform -chdir=terraform init
terraform -chdir=terraform validate
terraform -chdir=terraform plan
```

## Azure deployment

The Azure Terraform configuration creates the following resources:
- Azure Resource Group
- Azure Storage Account
- Azure Container Registry

Deploy:
```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply -auto-approve tfplan
```

## Jenkins pipeline (Azure version)

```groovy
pipeline {
    agent any

    environment {
        ARM_SUBSCRIPTION_ID = credentials('ARM_SUBSCRIPTION_ID')
        ARM_TENANT_ID = credentials('ARM_TENANT_ID')
        ARM_CLIENT_ID = credentials('ARM_CLIENT_ID')
        ARM_CLIENT_SECRET = credentials('ARM_CLIENT_SECRET')
        TF_VAR_location = 'eastus'
    }

    stages {
        stage('Checkout') {
            steps { checkout scm }
        }

        stage('Secret Scan') {
            steps {
                sh 'curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | bash'
                sh 'gitleaks detect --source . --no-banner --exit-code 1'
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker build -t devsecops-demo:latest .'
            }
        }

        stage('Container Scan') {
            steps {
                sh 'curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin'
                sh 'trivy image --severity HIGH,CRITICAL devsecops-demo:latest'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform -chdir=terraform init'
                sh 'terraform -chdir=terraform validate'
                sh 'terraform -chdir=terraform plan -out=tfplan'
            }
        }

        stage('Deploy Infrastructure') {
            steps {
                sh 'terraform -chdir=terraform apply -auto-approve tfplan'
            }
        }
    }
}
```

## GitLab CI (Azure version)

```yaml
stages:
  - scan
  - build
  - deploy

variables:
  TF_VAR_location: "eastus"

secret_scan:
  stage: scan
  image: python:3.11-slim
  script:
    - apt-get update && apt-get install -y curl
    - curl -sSfL https://raw.githubusercontent.com/gitleaks/gitleaks/master/install.sh | bash
    - gitleaks detect --source . --no-banner --exit-code 1

container_scan:
  stage: build
  image: docker:24
  services:
    - docker:dind
  script:
    - docker build -t devsecops-demo:latest .
    - docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v "$PWD:/workdir" aquasec/trivy:0.57.1 image --severity HIGH,CRITICAL devsecops-demo:latest

terraform_deploy:
  stage: deploy
  image: hashicorp/terraform:1.8.5
  script:
    - cd terraform
    - terraform init
    - terraform validate
    - terraform plan -out=tfplan
    - terraform apply -auto-approve tfplan
```

## Example expected output

```text
$ az login
You have logged in to Microsoft Azure.

$ terraform -chdir=terraform apply -auto-approve
azurerm_resource_group.rg: Creating...
azurerm_container_registry.acr: Creating...
azurerm_storage_account.sa: Creating...
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

$ trivy image --severity HIGH,CRITICAL devsecops-demo:latest
2026-10-14T10:00:00Z INFO  Vulnerability scanning is enabled
2026-10-14T10:00:00Z WARN  0 criticals, 1 high found
```

## Security notes

- Never commit Azure secrets or credentials directly to source control.
- Prefer Azure Key Vault, environment variables, or secure CI secret managers.
- Scan pipeline must fail on high-risk secret leaks or critical vulnerabilities.
- Treat Terraform changes as infrastructure policy gates.

## License

MIT
