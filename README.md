# BankPro Multi-Cloud DevOps Platform

Welcome to the production-grade multi-cloud infrastructure and deployment repository for **BankPro**, a Spring Boot microservice application. 

This repository contains a fully automated, modular infrastructure setup across **AWS** and **Azure** using Terraform, provisioning VMs with Ansible, packaging with Docker, and orchestrating deployments using either GitHub Actions or Jenkins.

---

## 1. Directory Structure

The repository is structured to separate infrastructure deployment configs from application source files:

```
├── App/                    # Application Source Files
│   ├── docker/             # Dockerfile & JVM memory-tuned runner script
│   ├── src/                # Spring Boot Microservice source code
│   └── pom.xml             # Maven Project specifications
│
├── deploy/                 # Infrastructure & Automation Configs
│   ├── terraform/          # Modular Terraform files
│   │   ├── environments/   # Environment vars: dev, stage, prod
│   │   └── modules/        # Reusable modules: networking, computes, scaling, security, monitoring
│   ├── ansible/            # Ansible provisioning and playbooks
│   │   ├── playbooks/      # site.yml (hosts setup) & deploy.yml (app release)
│   │   └── roles/          # docker, java, nginx, app-deploy (blue-green zero-downtime)
│   ├── github-actions/     # Pipeline Action Workflows (templates)
│   └── scripts/            # Helper automation scripts (SSH keygen, TF wrapper, Python runner)
│
├── .github/                # Active GitHub Actions pipeline workflows
└── Jenkinsfile             # Active Jenkins declarative pipeline
```

---

## 2. Prerequisites

Before starting, ensure you have the following installed and configured on your machine:

- **Terraform** (>= 1.6)
- **Ansible**
- **Docker**
- **Python** (3.x)
- **Maven** (3.8+)
- **AWS CLI** (configured with access keys to provision VPC, EC2, ALB, ECR)
- **Azure CLI** (configured to provision Resource Group, VNet, VMs, ACR)

---

## 3. Step-by-Step Manual Deployment Guide

Anyone can deploy this platform manually by following these 5 steps:

### Step 1: Generate SSH Deployment Keys
Run the provided helper script to generate the secure SSH keypair:
```bash
./deploy/scripts/deploy-ssh-setup.sh
```
This creates a key pair in `deploy/keys/bankpro_deploy_key`.

### Step 2: Configure and Deploy Terraform Infrastructure
1. Copy the public key content from `deploy/keys/bankpro_deploy_key.pub`.
2. Open the tfvars file for your target environment (e.g., `deploy/terraform/environments/dev/terraform.tfvars`) and paste it as the `ssh_public_key` value.
3. Run the Terraform wrapper script to deploy the infrastructure:
   ```bash
   # Initialize, plan, and apply for the dev environment
   ./deploy/scripts/tf-wrapper.sh dev init
   ./deploy/scripts/tf-wrapper.sh dev plan
   ./deploy/scripts/tf-wrapper.sh dev apply
   ```
   *Note: Save the outputs printed at the end of the apply (AWS ALB DNS, Azure Public IP).*

### Step 3: Generate the Ansible Inventory
Rather than manually editing the inventory `hosts.ini` file, execute the Python generator script. It automatically reads your active Terraform state and structures the inventory file with correct proxy routes for AWS private subnets:
```bash
python3 deploy/scripts/generate_inventory.py --env dev
```
This writes the dynamic configuration to `deploy/ansible/inventory/hosts.ini`.

### Step 4: Provision Host Infrastructure with Ansible
Run the provisioning playbook to install Docker, Java 17, and Nginx reverse proxy on all AWS and Azure target VMs:
```bash
cd deploy/ansible
ansible-playbook -i inventory/hosts.ini playbooks/site.yml
```

### Step 5: Deploy the BankPro Container (Blue-Green Zero-Downtime)
Run the application deployment playbook. This logs into your container registry, pulls the image, spins up the idle slot container (blue/green), verifies its health, swaps the Nginx upstream to redirect traffic, and shuts down the old slot container:
```bash
ansible-playbook -i inventory/hosts.ini playbooks/deploy.yml \
  -e "registry_server=<your-registry-url>" \
  -e "registry_username=<username>" \
  -e "registry_password=<password>" \
  -e "image_name=bankpro-microservice" \
  -e "image_tag=latest"
```

---

## 4. Pipeline Orchestration (Jenkins & GitHub Actions)

To avoid complex command scripts inside your CI/CD files, both the `Jenkinsfile` and GitHub workflows invoke the Python master script: **[`deploy/scripts/pipeline_runner.py`](file:///deploy/scripts/pipeline_runner.py)**. 

### GitHub Actions
The CD pipeline ([`.github/workflows/cd.yml`](file:///.github/workflows/cd.yml)) runs the stages automatically using the Python runner:
- `python3 deploy/scripts/pipeline_runner.py --stage terraform-apply --env dev`
- `python3 deploy/scripts/pipeline_runner.py --stage deploy --env dev ...`
- `python3 deploy/scripts/pipeline_runner.py --stage smoke-test --env dev`

### Jenkins Setup
Create a multi-branch or pipeline project referencing the root **[`Jenkinsfile`](file:///Jenkinsfile)**. Ensure the following Credentials are bound inside Jenkins:
- `bankpro-aws-credentials` (AWS access keys)
- `bankpro-azure-credentials` (Azure Service Principal keys)
- `bankpro-registry-credentials` (Registry login passwords)
- `bankpro-ssh-key` (The SSH private key generated in Step 1)

---

## 5. Production Best Practices

- **Remote State Locking**: Uncomment the backend block in `backend.tf` to configure S3/Azure Blob remote state storage with DynamoDB/Azure Lease locks before deploying to production.
- **Bastion Access Hardening**: Restrict inbound SSH (port 22) on AWS and Azure Network Security Groups to your corporate network range rather than leaving it public.
- **Secrets Management**: Always pull passwords, database connection strings, and registry tokens from Jenkins Credentials or GitHub Secrets at runtime. Never check them into Git.
- **Zero-Downtime Verification**: The Ansible `app-deploy` role verifies that the new container is returning `HTTP 200` before changing the Nginx configuration. This prevents broken builds from taking down the live application.
