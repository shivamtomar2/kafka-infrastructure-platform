variable "environment" { type = string }
variable "bastion_instance_type" { type = string }
variable "kafka_instance_type" { type = string }
variable "key_name" { type = string }
variable "public_subnet_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "bastion_sg_id" { type = string }
variable "kafka_sg_id" { type = string }
