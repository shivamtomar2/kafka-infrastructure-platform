pipeline {

    agent any

    options {
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
                    sh 'terraform plan'
                }
            }
        }

        stage('Terraform Apply') {
            steps {
                dir("${TF_DIR}") {
                    sh 'terraform apply -auto-approve'
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

        stage('Deploy Kafka') {
            steps {
                dir("${ANSIBLE_DIR}") {
                    sh '''
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
