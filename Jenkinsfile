// ==============================================================================
// Declarative Jenkinsfile using Python Master Pipeline Runner
// ==============================================================================
// Updated to use actual Jenkins Credential IDs mapped from the user's dashboard.

pipeline {
    agent any

    parameters {
        choice(name: 'DEPLOY_ENV', choices: ['dev', 'stage', 'prod'], description: 'Target deployment environment')
        booleanParam(name: 'RUN_TERRAFORM', defaultValue: true, description: 'Whether to run Terraform Apply')
        booleanParam(name: 'RUN_DEPLOYMENT', defaultValue: true, description: 'Whether to run Ansible Application deployment')
    }

    environment {
        // Pinned Credential IDs configured inside Jenkins Dashboard
        AWS_CREDS_ID      = 'aws-creds'
        REGISTRY_CREDS_ID = 'dockerhub-creds'
        SSH_KEY_CREDS_ID  = 'kubeadm-ssh-key2'

        // Docker Hub Container Registry parameters
        REGISTRY_SERVER   = 'docker.io'
        IMAGE_NAME        = 'dccloudimage/bankpro-microservice'
        IMAGE_TAG         = "${BUILD_NUMBER}"
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
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'ARM_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'ARM_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'ARM_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'ARM_SUBSCRIPTION_ID')
                ]) {
                    withEnv([
                        "AWS_DEFAULT_REGION=us-east-1",
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
