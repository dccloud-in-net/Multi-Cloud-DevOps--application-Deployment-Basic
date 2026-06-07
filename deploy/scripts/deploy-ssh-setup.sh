#!/usr/bin/env bash
# ==============================================================================
# SSH Key Generation & Automation Script
# ==============================================================================
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KEYS_DIR="${SCRIPT_DIR}/../keys"
KEY_NAME="bankpro_deploy_key"

echo "====================================================================="
echo " BankPro Multi-Cloud Key Setup"
echo "====================================================================="

if [ ! -d "${KEYS_DIR}" ]; then
    echo "Creating keys directory at '${KEYS_DIR}'..."
    mkdir -p "${KEYS_DIR}"
    chmod 700 "${KEYS_DIR}"
fi

if [ -f "${KEYS_DIR}/${KEY_NAME}" ]; then
    echo "SSH keys already exist at ${KEYS_DIR}/${KEY_NAME}."
else
    echo "Generating new secure SSH keypair (ED25519) without passphrase..."
    ssh-keygen -t ed25519 -N "" -f "${KEYS_DIR}/${KEY_NAME}" -C "devops@bankpro.com"
    chmod 600 "${KEYS_DIR}/${KEY_NAME}"
    chmod 644 "${KEYS_DIR}/${KEY_NAME}.pub"
    echo "SSH keypair generated successfully."
fi

echo "Private Key Path: ${KEYS_DIR}/${KEY_NAME}"
echo "Public Key Path:  ${KEYS_DIR}/${KEY_NAME}.pub"
echo "====================================================================="
