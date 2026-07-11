#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TF_DIR="$PROJECT_ROOT/terraform"
SSH_CONFIG="$HOME/.ssh/config"

START_MARKER="# BEGIN KAFKA INFRASTRUCTURE PLATFORM"
END_MARKER="# END KAFKA INFRASTRUCTURE PLATFORM"

echo "Reading Terraform outputs..."

BASTION_IP=$(terraform -chdir="$TF_DIR" output -raw bastion_public_ip)
BROKER1=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[0]')
BROKER2=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[1]')
BROKER3=$(terraform -chdir="$TF_DIR" output -json kafka_broker_private_ips | jq -r '.[2]')

mkdir -p "$HOME/.ssh"
touch "$SSH_CONFIG"

awk -v start="$START_MARKER" -v end="$END_MARKER" '
    $0 == start { skip=1; next }
    $0 == end   { skip=0; next }
    !skip       { print }
' "$SSH_CONFIG" > "${SSH_CONFIG}.tmp"

mv "${SSH_CONFIG}.tmp" "$SSH_CONFIG"

cat >> "$SSH_CONFIG" <<EOF_CONFIG

$START_MARKER
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
$END_MARKER
EOF_CONFIG

chmod 600 "$SSH_CONFIG"

echo "SSH config updated successfully."

for host in kafka-bastion kafka-broker-01 kafka-broker-02 kafka-broker-03; do
    echo "$host -> $(ssh -G "$host" | awk '/^hostname / {print $2; exit}')"
done
