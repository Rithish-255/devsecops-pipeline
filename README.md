# End-to-End DevSecOps Pipeline on Cloud

This project demonstrates a complete DevSecOps workflow for deploying containerized applications on AWS/Azure using:
- Terraform for infrastructure provisioning
- Trivy for container and filesystem vulnerability scanning
- Gitleaks for secret detection
- Jenkins or GitLab CI for automation

The repository is intentionally designed to be easy to run in a real cloud environment while staying safe for local experimentation.

## Architecture

[Diagram description: Developer pushes code -> GitLab/Jenkins pipeline -> Gitleaks scan -> Docker build -> Trivy scan -> Terraform plan/apply -> AWS/Azure resource deployment]

## Project structure

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

Install the following on the runner or local workstation:
- Docker
- Terraform >= 1.5
- Trivy
- Gitleaks
- AWS CLI or Azure CLI

For AWS:
```bash
aws configure
```

For Azure:
```bash
az login
```

## Quick local validation

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

## Jenkins pipeline usage

1. Create a Jenkins job pointing to this repository.
2. Add required environment variables:
   - AWS_ACCESS_KEY_ID
   - AWS_SECRET_ACCESS_KEY
   - AWS_DEFAULT_REGION
   - or Azure credentials in your preferred secure mechanism
3. Run the pipeline.

The included `Jenkinsfile` runs:
- checkout
- secret scan with Gitleaks
- container build
- image vulnerability scan with Trivy
- Terraform init/validate
- Terraform plan
- optional apply stage

## GitLab CI usage

The included `.gitlab-ci.yml` defines a pipeline with stages for:
- secret scan
- image scan
- infrastructure validation
- deployment

Set the project variables in GitLab CI if you want Terraform to apply to AWS or Azure.

## Terraform deployment

The Terraform configuration creates a basic AWS resource (S3 bucket) that demonstrates infrastructure provisioning after the scan stages pass.

Example:
```bash
terraform -chdir=terraform init
terraform -chdir=terraform plan -out=tfplan
terraform -chdir=terraform apply -auto-approve tfplan
```

## Security notes

- Do not commit secrets or API keys.
- Store credentials in CI/CD secret stores such as AWS IAM roles, Azure Key Vault, Jenkins credentials, or GitLab variables.
- Review Trivy findings before production deployment.
- Treat scan failures as policy gates.

## Example output

```text
$ gitleaks detect --source . --no-banner --exit-code 1
2026-10-14T10:00:00Z INFO  No leaks found
2026-10-14T10:00:00Z INFO  0 findings detected

$ trivy image --severity HIGH,CRITICAL devsecops-demo:latest
2026-10-14T10:00:00Z INFO  Vulnerability scanning is enabled
2026-10-14T10:00:00Z WARN  1 vulnerability found

$ terraform -chdir=terraform apply -auto-approve
aws_s3_bucket.artifact_store: Creating...
aws_s3_bucket.artifact_store: Creation complete after 12s
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

## License

This project is licensed under the MIT License.
