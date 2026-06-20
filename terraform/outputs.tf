output "vpc_id" {
  value = module.vpc.vpc_id
}

output "bastion_public_ip" {
  value = module.ec2.bastion_public_ip
}

output "kafka_broker_private_ips" {
  value = module.ec2.kafka_broker_private_ips
}
