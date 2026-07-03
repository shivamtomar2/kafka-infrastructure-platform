#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$PROJECT_ROOT/terraform"

echo "Reading Terraform outputs..."

BASTION_IP=$(terraform -chdir="$TF_DIR" output -raw bastion_public_ip)

BROKER1=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[0]')
BROKER2=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[1]')
BROKER3=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[2]')

cat > ~/.ssh/config <<EOF
Host kafka-bastion
    HostName $BASTION_IP
    User ubuntu
    IdentityFile ~/.ssh/kafka-key.pem
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host kafka-broker-01
    HostName $BROKER1
    User ubuntu
    IdentityFile ~/.ssh/kafka-key.pem
    ProxyJump kafka-bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host kafka-broker-02
    HostName $BROKER2
    User ubuntu
    IdentityFile ~/.ssh/kafka-key.pem
    ProxyJump kafka-bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host kafka-broker-03
    HostName $BROKER3
    User ubuntu
    IdentityFile ~/.ssh/kafka-key.pem
    ProxyJump kafka-bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null

Host 10.0.*
    User ubuntu
    IdentityFile ~/.ssh/kafka-key.pem
    ProxyJump kafka-bastion
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
EOF

chmod 600 ~/.ssh/config

echo
echo "SSH config updated successfully!"
echo

echo "=============================="
echo "SSH Configuration Verification"
echo "=============================="

echo
echo "Bastion:"
ssh -G kafka-bastion | grep hostname

echo
echo "Broker 01:"
ssh -G kafka-broker-01 | grep hostname

echo
echo "Broker 02:"
ssh -G kafka-broker-02 | grep hostname

echo
echo "Broker 03:"
ssh -G kafka-broker-03 | grep hostname

echo
echo "Done."
