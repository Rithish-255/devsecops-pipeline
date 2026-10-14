pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'
        TF_VAR_aws_region = 'us-east-1'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
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
