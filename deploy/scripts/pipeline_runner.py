#!/usr/bin/env python3
# ==============================================================================
# Master Pipeline Runner Script for BankPro Multi-Cloud Platform
# ==============================================================================
# This Python script encapsulates all pipeline lifecycle operations (build, test,
# docker publish, terraform provisioning, ansible deployment, and smoke testing).
# It replaces complex shell scripting and step logic inside Jenkinsfile & GHA.

import argparse
import os
import subprocess
import sys
import urllib.request
import time

def check_java_bin_version(bin_path):
    """Runs the java/javac binary with -version and returns the major version number."""
    try:
        res = subprocess.run([bin_path, "-version"], capture_output=True, text=True)
        output = res.stdout + res.stderr
        for line in output.splitlines():
            if "version" in line or line.startswith("javac") or line.startswith("java"):
                parts = line.split()
                for part in parts:
                    part = part.strip('"')
                    if part.replace(".", "").replace("_", "").isdigit() or (len(part.split(".")) >= 2 and part.split(".")[0].isdigit()):
                        ver_str = part
                        major = int(ver_str.split(".")[1]) if ver_str.startswith("1.") else int(ver_str.split(".")[0])
                        return major
    except Exception:
        pass
    return None

def setup_java_home():
    """Detects if Java is >= 17, and configures JAVA_HOME to a compatible version if not."""
    # 1. Check if existing JAVA_HOME is compatible
    java_home = os.environ.get("JAVA_HOME")
    if java_home:
        javac_path = os.path.join(java_home, "bin", "javac")
        java_path = os.path.join(java_home, "bin", "java")
        javac_ver = check_java_bin_version(javac_path)
        java_ver = check_java_bin_version(java_path)
        if javac_ver and java_ver and javac_ver >= 17 and java_ver >= 17:
            print(f"JAVA_HOME is already configured to a compatible version: {java_ver} ({java_home})")
            return
        else:
            print(f"Existing JAVA_HOME ({java_home}) is incompatible (javac: {javac_ver}, java: {java_ver}). Searching for compatible JDK...")

    # 2. If no compatible JAVA_HOME, check default system java & javac in PATH
    if not java_home:
        javac_ver = check_java_bin_version("javac")
        java_ver = check_java_bin_version("java")
        if javac_ver and java_ver and javac_ver >= 17 and java_ver >= 17:
            print(f"Default system java ({java_ver}) and javac ({javac_ver}) are compatible. No override needed.")
            return
        else:
            print(f"Default system Java is incompatible or mismatched (javac: {javac_ver}, java: {java_ver}). Searching for compatible JDK...")

    # 3. Search for any installed JDK >= 17 on Linux/Unix
    search_paths = ["/usr/lib/jvm", "/usr/java", "/opt"]
    found_path = None
    
    candidate_versions = ["17", "21", "22", "23", "24", "18", "19", "20"]
    for base in search_paths:
        if os.path.exists(base):
            try:
                entries = os.listdir(base)
                for version in candidate_versions:
                    for entry in entries:
                        full_path = os.path.join(base, entry)
                        if os.path.isdir(full_path) and version in entry:
                            javac_path = os.path.join(full_path, "bin", "javac")
                            java_path = os.path.join(full_path, "bin", "java")
                            if os.path.exists(javac_path) and os.path.exists(java_path):
                                javac_ver = check_java_bin_version(javac_path)
                                java_ver = check_java_bin_version(java_path)
                                if javac_ver and java_ver and javac_ver >= 17 and java_ver >= 17:
                                    found_path = full_path
                                    break
                    if found_path:
                        break
                if found_path:
                    break
            except Exception:
                pass

    # 4. Search on macOS
    if not found_path and sys.platform == "darwin":
        mac_base = "/Library/Java/JavaVirtualMachines"
        if os.path.exists(mac_base):
            try:
                entries = os.listdir(mac_base)
                for version in candidate_versions:
                    for entry in entries:
                        full_path = os.path.join(mac_base, entry, "Contents/Home")
                        javac_path = os.path.join(full_path, "bin", "javac")
                        java_path = os.path.join(full_path, "bin", "java")
                        if os.path.exists(javac_path) and os.path.exists(java_path):
                            if version in entry:
                                javac_ver = check_java_bin_version(javac_path)
                                java_ver = check_java_bin_version(java_path)
                                if javac_ver and java_ver and javac_ver >= 17 and java_ver >= 17:
                                    found_path = full_path
                                    break
                    if found_path:
                        break
            except Exception:
                pass

    if found_path:
        print(f"Configuring pipeline environment to use detected JDK at: {found_path}")
        os.environ["JAVA_HOME"] = found_path
        os.environ["PATH"] = os.path.join(found_path, "bin") + os.pathsep + os.environ.get("PATH", "")
    else:
        print("Warning: Compatible Java version (>= 17) not auto-detected. Relying on system default Java.")

def run_command(command, cwd=None, env=None):
    """Utility function to safely execute shell commands and stream output."""
    print(f"Running command: {' '.join(command)}")
    try:
        # Launch the subprocess and stream logs directly to standard outputs
        result = subprocess.run(
            command,
            cwd=cwd,
            env=env,
            text=True,
            check=True
        )
        return True
    except subprocess.CalledProcessError as e:
        print(f"Command failed with exit code {e.returncode}", file=sys.stderr)
        if e.stderr:
            print(f"Stderr: {e.stderr}", file=sys.stderr)
        sys.exit(e.returncode)

def stage_build_test(root_dir):
    """Executes Maven clean build package and unit tests."""
    print("\n=== STAGE: Maven Build & Unit Testing ===")
    
    # Run maven packaging (skipping tests temporarily to isolate compilation)
    run_command(["mvn", "-f", "App/pom.xml", "clean", "package", "-B", "-DskipTests"], cwd=root_dir)
    
    # Run the core Junit tests
    run_command(["mvn", "-f", "App/pom.xml", "test", "-B"], cwd=root_dir)

def stage_docker_push(root_dir, registry, image, tag, username, password):
    """Builds the Spring Boot Docker image and pushes it to ECR/ACR registries."""
    print("\n=== STAGE: Docker Image Build & Push ===")
    
    # 1. Compile the docker image using the multi-stage Dockerfile
    dockerfile_path = os.path.join(root_dir, "App/docker/Dockerfile")
    build_context = os.path.join(root_dir, "App")
    image_uri = f"{registry}/{image}:{tag}"
    latest_uri = f"{registry}/{image}:latest"
    
    run_command(["docker", "build", "-t", f"{image}:{tag}", "-f", dockerfile_path, build_context])
    
    # 2. Log in to the target registry if credentials are provided
    if username and password:
        login_cmd = ["docker", "login", registry, "-u", username, "--password-stdin"]
        print(f"Logging in to docker registry: {registry}")
        try:
            p = subprocess.Popen(login_cmd, stdin=subprocess.PIPE, text=True)
            p.communicate(input=password)
            if p.returncode != 0:
                print("Docker login failed.", file=sys.stderr)
                sys.exit(p.returncode)
        except Exception as e:
            print(f"Failed to login: {e}", file=sys.stderr)
            sys.exit(1)

    # 3. Tag and push target versions
    run_command(["docker", "tag", f"{image}:{tag}", image_uri])
    run_command(["docker", "tag", f"{image}:{tag}", latest_uri])
    run_command(["docker", "push", image_uri])
    run_command(["docker", "push", latest_uri])

def stage_terraform(root_dir, env, action):
    """Initializes and runs Terraform actions (plan/apply/destroy)."""
    print(f"\n=== STAGE: Terraform {action.capitalize()} ===")
    
    env_dir = os.path.join(root_dir, "deploy/terraform/environments", env)
    
    # Initialize workspace providers and backend modules
    run_command(["terraform", "init"], cwd=env_dir)
    
    # Validate configuration syntax correctness
    run_command(["terraform", "validate"], cwd=env_dir)
    
    if action == "apply":
        # Generate plan file and apply automatically
        run_command(["terraform", "plan", "-out=tfplan"], cwd=env_dir)
        run_command(["terraform", "apply", "-auto-approve", "tfplan"], cwd=env_dir)
    elif action == "destroy":
        # Destroy infrastructure nodes
        run_command(["terraform", "destroy", "-auto-approve"], cwd=env_dir)

def stage_ansible(root_dir, env, registry, image, tag, username, password):
    """Generates inventory dynamically and runs Ansible site/deploy playbooks."""
    print("\n=== STAGE: Ansible Provisioning & Deployment ===")
    
    # 1. Run the inventory generator script to construct hosts.ini
    generator_script = os.path.join(root_dir, "deploy/scripts/generate_inventory.py")
    run_command([sys.executable, generator_script, "--env", env], cwd=root_dir)
    
    ansible_dir = os.path.join(root_dir, "deploy/ansible")
    
    # 2. Run Ansible playbook to provision host servers (install Docker, Java, Nginx)
    run_command(["ansible-playbook", "-i", "inventory/hosts.ini", "playbooks/site.yml"], cwd=ansible_dir)
    
    # 3. Run application deployment playbook (executes zero-downtime blue-green swap)
    deploy_cmd = [
        "ansible-playbook", "-i", "inventory/hosts.ini", "playbooks/deploy.yml",
        "-e", f"registry_server={registry}",
        "-e", f"image_name={image}",
        "-e", f"image_tag={tag}"
    ]
    if username and password:
        deploy_cmd.extend([
            "-e", f"registry_username={username}",
            "-e", f"registry_password={password}"
        ])
    
    run_command(deploy_cmd, cwd=ansible_dir)

def stage_smoke_test(root_dir, env):
    """Fetches ALB/LB IPs from Terraform and runs curl health checks."""
    print("\n=== STAGE: Smoke Testing & Verification ===")
    
    env_dir = os.path.join(root_dir, "deploy/terraform/environments", env)
    
    # Retrieve public endpoints from Terraform outputs
    try:
        aws_alb = subprocess.check_output(
            ["terraform", "output", "-raw", "aws_alb_dns_name"],
            cwd=env_dir, text=True
        ).strip()
        azure_lb = subprocess.check_output(
            ["terraform", "output", "-raw", "azure_lb_public_ip"],
            cwd=env_dir, text=True
        ).strip()
    except subprocess.CalledProcessError as e:
        print("Failed to fetch load balancer outputs from Terraform.", file=sys.stderr)
        sys.exit(1)

    endpoints = {
        "AWS ALB Endpoint": f"http://{aws_alb}",
        "Azure Load Balancer": f"http://{azure_lb}"
    }

    # Probes endpoints with retries
    for name, url in endpoints.items():
        print(f"Testing {name}: {url}")
        success = False
        for attempt in range(5):
            try:
                # Issue simple HTTP request
                with urllib.request.urlopen(url, timeout=10) as response:
                    if response.status == 200:
                        print(f"SUCCESS: {name} returned status code 200.")
                        success = True
                        break
            except Exception as e:
                print(f"Attempt {attempt+1} failed: {e}. Retrying in 10s...")
                time.sleep(10)
        
        if not success:
            print(f"ERROR: {name} failed health probe validation.", file=sys.stderr)
            sys.exit(1)

    print("All multi-cloud endpoints are healthy and active!")

def main():
    parser = argparse.ArgumentParser(description="Master pipeline runner for BankPro CI/CD.")
    parser.add_argument("--stage", required=True, choices=["build", "push", "terraform-apply", "terraform-destroy", "deploy", "smoke-test", "all"])
    parser.add_argument("--env", default="dev", choices=["dev", "stage", "prod"])
    
    # Registry auth params
    parser.add_argument("--registry", default="")
    parser.add_argument("--image", default="bankpro-microservice")
    parser.add_argument("--tag", default="latest")
    parser.add_argument("--username", default="")
    parser.add_argument("--password", default="")

    args = parser.parse_args()

    # Automatically set up Java 17 environment
    setup_java_home()

    script_dir = os.path.dirname(os.path.realpath(__file__))
    root_dir = os.path.abspath(os.path.join(script_dir, "../.."))

    # Execute target stage
    if args.stage == "build":
        stage_build_test(root_dir)
    elif args.stage == "push":
        if not args.registry:
            print("Error: --registry is required for push stage.", file=sys.stderr)
            sys.exit(1)
        stage_docker_push(root_dir, args.registry, args.image, args.tag, args.username, args.password)
    elif args.stage == "terraform-apply":
        stage_terraform(root_dir, args.env, "apply")
    elif args.stage == "terraform-destroy":
        stage_terraform(root_dir, args.env, "destroy")
    elif args.stage == "deploy":
        stage_ansible(root_dir, args.env, args.registry, args.image, args.tag, args.username, args.password)
    elif args.stage == "smoke-test":
        stage_smoke_test(root_dir, args.env)
    elif args.stage == "all":
        stage_build_test(root_dir)
        stage_docker_push(root_dir, args.registry, args.image, args.tag, args.username, args.password)
        stage_terraform(root_dir, args.env, "apply")
        stage_ansible(root_dir, args.env, args.registry, args.image, args.tag, args.username, args.password)
        stage_smoke_test(root_dir, args.env)

if __name__ == "__main__":
    main()
