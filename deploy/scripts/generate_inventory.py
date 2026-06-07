#!/usr/bin/env python3
import json
import subprocess
import sys
import os
import argparse

def get_terraform_outputs(env_dir):
    """Runs terraform output -json and parses the results."""
    try:
        # Run terraform output from the specific environment folder
        result = subprocess.run(
            ["terraform", "output", "-json"],
            cwd=env_dir,
            capture_output=True,
            text=True,
            check=True
        )
        return json.loads(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error executing terraform output: {e.stderr}", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error parsing terraform output JSON: {e}", file=sys.stderr)
        sys.exit(1)

def main():
    parser = argparse.ArgumentParser(description="Generate Ansible inventory from Terraform outputs.")
    parser.add_argument("--env", required=True, choices=["dev", "stage", "prod"], help="Target environment")
    args = parser.parse_args()

    # Establish relative directories
    script_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.abspath(os.path.join(script_dir, "../.."))
    env_dir = os.path.join(root_dir, "deploy/terraform/environments", args.env)
    inventory_file = os.path.join(root_dir, "deploy/ansible/inventory/hosts.ini")

    if not os.path.exists(env_dir):
        print(f"Environment directory not found: {env_dir}", file=sys.stderr)
        sys.exit(1)

    print(f"Fetching Terraform outputs from: {env_dir}")
    outputs = get_terraform_outputs(env_dir)

    # Extract required fields safely
    try:
        bastion_ip = outputs.get("aws_bastion_public_ip", {}).get("value", "")
        aws_app_ips = outputs.get("aws_app_private_ips", {}).get("value", [])
        azure_vm_ips = outputs.get("azure_vm_public_ips", {}).get("value", [])
    except Exception as e:
        print(f"Error extracting parameters from Terraform outputs: {e}", file=sys.stderr)
        sys.exit(1)

    print("Generating hosts.ini content...")
    inventory_lines = []
    
    # 1. Bastion section
    inventory_lines.append("[aws_bastion]")
    if bastion_ip:
        inventory_lines.append(
            f"aws-bastion-host ansible_host={bastion_ip} ansible_user=ec2-user "
            f"ansible_ssh_private_key_file=../keys/bankpro_deploy_key"
        )
    inventory_lines.append("")

    # 2. AWS application servers section (accessed via Bastion Proxy)
    inventory_lines.append("[aws_app_servers]")
    if bastion_ip:
        for idx, ip in enumerate(aws_app_ips):
            inventory_lines.append(
                f"aws-node-{idx+1} ansible_host={ip} ansible_user=ec2-user "
                f"ansible_ssh_private_key_file=../keys/bankpro_deploy_key "
                f"ansible_ssh_common_args='-o ProxyCommand=\"ssh -W %h:%p -q ec2-user@{bastion_ip} "
                f"-i ../keys/bankpro_deploy_key -o StrictHostKeyChecking=no\"'"
            )
    inventory_lines.append("")

    # 3. Azure application servers section
    inventory_lines.append("[azure_app_servers]")
    for idx, ip in enumerate(azure_vm_ips):
        inventory_lines.append(
            f"azure-node-{idx+1} ansible_host={ip} ansible_user=azureuser "
            f"ansible_ssh_private_key_file=../keys/bankpro_deploy_key"
        )
    inventory_lines.append("")

    # 4. Children groups
    inventory_lines.append("[app_servers:children]")
    inventory_lines.append("aws_app_servers")
    inventory_lines.append("azure_app_servers")
    inventory_lines.append("")

    # Ensure inventory parent directory exists
    os.makedirs(os.path.dirname(inventory_file), exist_ok=True)

    # Write file out
    with open(inventory_file, "w") as f:
        f.write("\n".join(inventory_lines))

    print(f"Ansible inventory successfully written to: {inventory_file}")

if __name__ == "__main__":
    main()
