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
        TF_DIR         = 'terraform'
        ANSIBLE_DIR    = 'ansible'
        ANSIBLE_CONFIG = "${WORKSPACE}/ansible/ansible.cfg"
        PATH           = "/opt/homebrew/bin:/opt/anaconda3/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Environment') {
            steps {
                sh '''
                    set -e

                    echo "Workspace: $WORKSPACE"
                    echo "Home: $HOME"

                    terraform version
                    aws --version
                    python3 --version
                    git --version
                    ssh -V

                    aws sts get-caller-identity
                    test -f "$HOME/.ssh/kafka-key.pem"
                '''
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
                    sh 'terraform init -input=false'
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
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -input=false -auto-approve tfplan'
                }
            }
        }

        stage('Update SSH Config') {
            steps {
                sh '''
                    chmod +x scripts/update_ssh_config.sh
                    ./scripts/update_ssh_config.sh
                '''
            }
        }

        stage('Wait For SSH') {
            steps {
                sh '''
                    set -e

                    for host in kafka-bastion kafka-broker-01 kafka-broker-02 kafka-broker-03
                    do
                        echo "Waiting for $host..."

                        ready=false

                        for attempt in $(seq 1 18)
                        do
                            if ssh \
                                -o BatchMode=yes \
                                -o ConnectTimeout=10 \
                                "$host" hostname >/dev/null 2>&1
                            then
                                echo "$host is ready."
                                ready=true
                                break
                            fi

                            echo "$host not ready - attempt $attempt/18"
                            sleep 10
                        done

                        if [ "$ready" != "true" ]
                        then
                            echo "ERROR: $host did not become reachable."
                            exit 1
                        fi
                    done
                '''
            }
        }

        stage('Prepare Ansible Environment') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        set -e

                        python3 -m venv .venv
                        . .venv/bin/activate

                        python -m pip install --upgrade pip
                        pip install -r requirements.txt

                        ansible-galaxy collection install amazon.aws --force

                        ansible --version
                        ansible-inventory -i aws_ec2.yml --graph
                    '''
                }
            }
        }

        stage('Ansible Connectivity') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        set -e
                        . .venv/bin/activate

                        ansible role_kafka \
                            -i aws_ec2.yml \
                            -m ping
                    '''
                }
            }
        }

        stage('Deploy Kafka') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
                        set -e
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
                        set -e
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
            echo ' Check the failed Jenkins stage logs'
            echo '======================================='
        }

        always {
            sh '''
                rm -f terraform/tfplan || true
            '''
            echo 'Pipeline finished.'
        }
    }
}
