#!/bin/bash

set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

TF_DIR="$PROJECT_ROOT/terraform"

BASTION_IP=$(terraform -chdir="$TF_DIR" output -raw bastion_public_ip)

cat > "$PROJECT_ROOT/ansible/group_vars/all.yml" <<YAML
---
#################################################
# SSH Configuration
#################################################

ansible_user: ubuntu

ansible_ssh_private_key_file: ~/.ssh/kafka-key.pem

ansible_ssh_common_args: >-
  -o StrictHostKeyChecking=no
  -o ProxyCommand="ssh -W %h:%p -i ~/.ssh/kafka-key.pem ubuntu@$BASTION_IP"

#################################################
# Kafka Version
#################################################

kafka_version: "3.7.1"
kafka_scala_version: "2.13"

#################################################
# Kafka Download
#################################################

kafka_download_url: "https://archive.apache.org/dist/kafka/{{ kafka_version }}/kafka_{{ kafka_scala_version }}-{{ kafka_version }}.tgz"

#################################################
# Kafka Cluster
#################################################

kafka_cluster_id: "LpJFO8ZTRe6yI4NvteWRkQ"

#################################################
# Kafka Heap
#################################################

kafka_heap_xms: "128M"
kafka_heap_xmx: "256M"

#################################################
# Kafka Directories
#################################################

kafka_install_dir: "/opt/kafka"

kafka_log_dir: "/tmp/kraft-combined-logs"
YAML

echo
echo "======================================"
echo "Ansible variables updated successfully"
echo "Bastion IP : $BASTION_IP"
echo "======================================"
