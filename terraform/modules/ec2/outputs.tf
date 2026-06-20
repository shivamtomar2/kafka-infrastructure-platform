output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "kafka_broker_private_ips" {
  value = aws_instance.kafka_brokers[*].private_ip
}
