pipeline {

    agent any

    options {
        skipDefaultCheckout(true)
        timestamps()
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    environment {
        TF_DIR = "terraform"
        ANSIBLE_DIR = "ansible"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Format') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform fmt -check -recursive'
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform init'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform validate'
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform plan -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }

        stage('Update SSH Config') {
            steps {
                sh './scripts/update_ssh_config.sh'
            }
        }

        stage('Wait For SSH') {
            steps {
                sleep(time: 30, unit: 'SECONDS')
            }
        }

        stage('Prepare Ansible Environment') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                    python3 -m venv .venv

                    . .venv/bin/activate

                    python -m pip install --upgrade pip

                    pip install -r requirements.txt

                    ansible-galaxy collection install amazon.aws
                    '''
                }
            }
        }

        stage('Deploy Kafka') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                    . .venv/bin/activate

                    ansible-playbook \
                        -i aws_ec2.yml \
                        playbooks/deploy_kafka.yml
                    '''
                }
            }
        }

        stage('Kafka Health Check') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                    . .venv/bin/activate

                    ansible-playbook \
                        -i aws_ec2.yml \
                        playbooks/health_check.yml
                    '''
                }
            }
        }
    }

    post {

        success {
            echo '======================================='
            echo ' Kafka Cluster deployed successfully'
            echo '======================================='
        }

        failure {
            echo '======================================='
            echo ' Deployment failed'
            echo ' Check stage logs'
            echo '======================================='
        }

        always {
            echo "Pipeline finished."
        }
    }
}
