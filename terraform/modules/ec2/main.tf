data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "bastion" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.bastion_instance_type
  subnet_id     = var.public_subnet_id

  vpc_security_group_ids = [var.bastion_sg_id]
  key_name               = var.key_name

  tags = {
    Name        = "kafka-bastion"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}

resource "aws_instance" "kafka_brokers" {
  count         = 3
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.kafka_instance_type
  subnet_id     = var.private_subnet_ids[count.index]

  vpc_security_group_ids = [var.kafka_sg_id]
  key_name               = var.key_name

  tags = {
    Name        = "kafka-broker-0${count.index + 1}"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}
