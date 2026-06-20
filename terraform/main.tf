module "vpc" {
  source = "./modules/vpc"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private_subnet_cidrs = var.private_subnet_cidrs
  availability_zones   = var.availability_zones
}

module "security_group" {
  source = "./modules/security-group"

  environment = var.environment
  vpc_id      = module.vpc.vpc_id
  vpc_cidr    = var.vpc_cidr
}

module "ec2" {
  source = "./modules/ec2"

  environment           = var.environment
  bastion_instance_type = var.bastion_instance_type
  kafka_instance_type   = var.kafka_instance_type
  key_name              = var.key_name
  public_subnet_id      = module.vpc.public_subnet_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  bastion_sg_id         = module.security_group.bastion_sg_id
  kafka_sg_id           = module.security_group.kafka_sg_id
}
