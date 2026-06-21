# Kafka Infrastructure Platform

End-to-end Kafka Infrastructure Platform deployed on AWS using Terraform, Ansible, and Jenkins.

## Overview

This project automates the provisioning, configuration, and deployment of a distributed Apache Kafka cluster in KRaft mode.

The complete deployment pipeline is implemented using:

- Terraform (Infrastructure as Code)
- Ansible (Configuration Management)
- Jenkins (CI/CD Automation)
- Apache Kafka (Distributed Event Streaming Platform)
- AWS EC2, VPC, Subnets, Security Groups

---

## Architecture

```text
Developer
    │
    ▼
 Jenkins Pipeline
    │
    ▼
 Terraform
    │
    ▼
 AWS Infrastructure
    │
    ├── Bastion Host
    │
    ├── Kafka Broker 1
    ├── Kafka Broker 2
    └── Kafka Broker 3
            │
            ▼
      Kafka KRaft Cluster
```

---

## Components

### Terraform

Responsible for provisioning:

- VPC
- Public Subnet
- Private Subnets
- Internet Gateway
- NAT Gateway
- Security Groups
- Bastion Host
- Kafka Broker EC2 Instances

### Ansible

Responsible for:

- Installing Java 17
- Installing Kafka 3.7.1
- Configuring KRaft Mode
- Configuring Broker IDs
- Configuring Controller Quorum
- Starting Kafka Services
- Validating Cluster Health

### Jenkins

Provides one-click deployment by executing:

```bash
terraform init
terraform apply
ansible-playbook deploy_kafka.yml
```

---

## Kafka Cluster Details

| Component | Value |
|------------|------------|
| Kafka Version | 3.7.1 |
| Mode | KRaft |
| Brokers | 3 |
| Partitions | 3 |
| Replication Factor | 3 |

---

## Project Structure

```text
kafka-infrastructure-platform/
│
├── terraform/
│   ├── modules/
│   ├── backend.tf
│   ├── main.tf
│   ├── outputs.tf
│   ├── providers.tf
│   └── variables.tf
│
├── ansible/
│   ├── inventory/
│   ├── playbooks/
│   ├── roles/
│   └── ansible.cfg
│
├── jenkins/
│
├── docs/
│
└── deploy.sh
```

---

## Deployment Workflow

### Step 1

Trigger Jenkins Job

```text
Build Now
```

### Step 2

Terraform provisions infrastructure.

### Step 3

Ansible configures Kafka cluster.

### Step 4

Kafka validation runs automatically.

### Step 5

Deployment completes successfully.

---

## Kafka Validation

Create Topic:

```bash
/opt/kafka/bin/kafka-topics.sh \
--create \
--topic orders \
--partitions 3 \
--replication-factor 3 \
--bootstrap-server <broker-ip>:9092
```

Describe Topic:

```bash
/opt/kafka/bin/kafka-topics.sh \
--describe \
--topic orders \
--bootstrap-server <broker-ip>:9092
```

---

## Producer

```bash
/opt/kafka/bin/kafka-console-producer.sh \
--topic orders \
--bootstrap-server <broker-ip>:9092
```

Sample Event:

```json
{"event":"platform_ready","status":"success"}
```

---

## Consumer

```bash
/opt/kafka/bin/kafka-console-consumer.sh \
--topic orders \
--from-beginning \
--bootstrap-server <broker-ip>:9092
```

---

## Demo Results

Successfully demonstrated:

- Infrastructure Provisioning using Terraform
- Kafka Cluster Deployment using Ansible
- CI/CD Automation using Jenkins
- Topic Creation
- Producer-Consumer Communication
- Event Streaming Validation

---

## Author

Shivam Tomar

B.Tech Computer Science Engineering
