#!/usr/bin/env bash
# ==============================================================================
# Terraform Wrapper Script for Multi-Cloud Environments
# ==============================================================================
set -euo pipefail

# Configurations
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TERRAFORM_DIR="${PROJECT_ROOT}/terraform"

show_usage() {
    echo "Usage: $0 [environment] [action]"
    echo "  environment : dev | stage | prod"
    echo "  action      : init | validate | plan | apply | destroy"
    echo "Example: $0 dev plan"
}

if [ "$#" -lt 2 ]; then
    show_usage
    exit 1
fi

ENV="$1"
ACTION="$2"
ENV_PATH="${TERRAFORM_DIR}/environments/${ENV}"

if [ ! -d "${ENV_PATH}" ]; then
    echo "Error: Environment '${ENV}' not found at '${ENV_PATH}'."
    exit 1
fi

cd "${ENV_PATH}"

echo "====================================================================="
echo " Environment : ${ENV}"
echo " Action      : ${ACTION}"
echo " Working Dir : ${ENV_PATH}"
echo "====================================================================="

case "${ACTION}" in
    init)
        echo "Running: terraform init..."
        terraform init
        ;;
    validate)
        echo "Running: terraform validate..."
        terraform validate
        ;;
    plan)
        echo "Running: terraform plan..."
        terraform plan -var-file="terraform.tfvars" -out="tfplan-${ENV}"
        ;;
    apply)
        echo "Running: terraform apply..."
        if [ -f "tfplan-${ENV}" ]; then
            terraform apply "tfplan-${ENV}"
            rm "tfplan-${ENV}"
        else
            terraform apply -var-file="terraform.tfvars" -auto-approve
        fi
        ;;
    destroy)
        echo "WARNING: You are about to DESTROY the environment: ${ENV}"
        read -p "Are you sure you want to proceed? (yes/no): " CONFIRM
        if [ "${CONFIRM}" = "yes" ]; then
            terraform destroy -var-file="terraform.tfvars" -auto-approve
        else
            echo "Action cancelled."
        fi
        ;;
    *)
        echo "Error: Invalid action '${ACTION}'."
        show_usage
        exit 1
        ;;
esac
