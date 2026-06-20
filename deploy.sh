#!/bin/bash

set -e

echo "========== Terraform =========="

cd terraform

terraform init

terraform apply -auto-approve

echo "========== Ansible =========="

cd ../ansible

source venv/bin/activate

ansible-playbook playbooks/deploy_kafka.yml

echo "========== Kafka Validation =========="

ansible kafka \
-i inventory/hosts \
-m shell \
-a "/opt/kafka/bin/kafka-topics.sh --version"
