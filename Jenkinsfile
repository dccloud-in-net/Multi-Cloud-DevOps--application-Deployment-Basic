// ==============================================================================
// Declarative Jenkinsfile using Python Master Pipeline Runner
// ==============================================================================
// This pipeline configuration has 0 inline custom scripting blocks. It delegates
// all execution stages directly to the Python master script (pipeline_runner.py).

pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'stage', 'prod'], description: 'Target deployment environment')
        booleanParam(name: 'RUN_TERRAFORM', defaultValue: true, description: 'Whether to run Terraform Apply')
        booleanParam(name: 'RUN_DEPLOYMENT', defaultValue: true, description: 'Whether to run Ansible Application deployment')
    }

    environment {
        // Pinned Credential IDs configured inside Jenkins
        AWS_CREDS_ID     = 'bankpro-aws-credentials'
        AZURE_CREDS_ID   = 'bankpro-azure-credentials'
        REGISTRY_CREDS_ID = 'bankpro-registry-credentials'
        SSH_KEY_CREDS_ID  = 'bankpro-ssh-key'

        // Container Registry parameters
        REGISTRY_SERVER  = 'bankproregistryprodsub.azurecr.io'
        IMAGE_NAME       = 'bankpro-microservice'
        IMAGE_TAG        = "${BUILD_NUMBER}"
    }

    options {
        timeout(time: 2, unit: 'HOURS')
        ansiColor('xterm')
        disableConcurrentBuilds()
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
            }
        }

        stage('Maven Build & Test') {
            steps {
                // Call master Python runner to compile and execute unit tests
                sh "python3 deploy/scripts/pipeline_runner.py --stage build"
            }
        }

        stage('Docker Build & Push') {
            steps {
                // Bind registry username/password and call Python runner
                withCredentials([usernamePassword(credentialsId: "${REGISTRY_CREDS_ID}", usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')]) {
                    sh """
                        python3 deploy/scripts/pipeline_runner.py --stage push \
                            --registry ${REGISTRY_SERVER} \
                            --image ${IMAGE_NAME} \
                            --tag ${IMAGE_TAG} \
                            --username ${REG_USER} \
                            --password ${REG_PASS}
                    """
                }
            }
        }

        stage('Terraform Apply') {
            when {
                expression { return params.RUN_TERRAFORM }
            }
            steps {
                // Bind cloud provider credentials and call Python runner to execute Terraform lifecycle
                withCredentials([
                    usernamePassword(credentialsId: "${AWS_CREDS_ID}", usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY'),
                    usernamePassword(credentialsId: "${AZURE_CREDS_ID}", usernameVariable: 'ARM_CLIENT_ID', passwordVariable: 'ARM_CLIENT_SECRET')
                ]) {
                    withEnv([
                        "AWS_DEFAULT_REGION=us-east-1",
                        "ARM_SUBSCRIPTION_ID=placeholder-subscription-id",
                        "ARM_TENANT_ID=placeholder-tenant-id"
                    ]) {
                        sh "python3 deploy/scripts/pipeline_runner.py --stage terraform-apply --env ${params.DEPLOY_ENV}"
                    }
                }
            }
        }

        stage('Ansible Provision & Deploy') {
            when {
                expression { return params.RUN_DEPLOYMENT }
            }
            steps {
                // Bind SSH Key & Registry Credentials, then call Python runner to build inventory and trigger playbooks
                withCredentials([
                    sshUserPrivateKey(credentialsId: "${SSH_KEY_CREDS_ID}", keyFileVariable: 'PRIVATE_KEY_PATH'),
                    usernamePassword(credentialsId: "${REGISTRY_CREDS_ID}", usernameVariable: 'REG_USER', passwordVariable: 'REG_PASS')
                ]) {
                    sh """
                        # Setup transient keys
                        mkdir -p deploy/keys
                        cp ${PRIVATE_KEY_PATH} deploy/keys/bankpro_deploy_key
                        chmod 600 deploy/keys/bankpro_deploy_key

                        # Call Python runner to generate hosts and execute plays
                        python3 deploy/scripts/pipeline_runner.py --stage deploy \
                            --env ${params.DEPLOY_ENV} \
                            --registry ${REGISTRY_SERVER} \
                            --image ${IMAGE_NAME} \
                            --tag ${IMAGE_TAG} \
                            --username ${REG_USER} \
                            --password ${REG_PASS}
                    """
                }
            }
        }

        stage('Smoke Test') {
            steps {
                // Call master Python runner to fetch endpoints and verify status codes
                sh "python3 deploy/scripts/pipeline_runner.py --stage smoke-test --env ${params.DEPLOY_ENV}"
            }
        }
    }

    post {
        always {
            // Clean secure artifacts
            sh 'rm -f deploy/keys/bankpro_deploy_key'
            cleanWs()
        }
        success {
            echo "BankPro Multi-cloud Platform deployed successfully!"
        }
        failure {
            echo "BankPro deployment pipeline failed. Check console outputs."
        }
    }
}
