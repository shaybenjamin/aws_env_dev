resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
}

module "networking" {
  source = "./modules/networking"

  region               = var.region
  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = local.production_availability_zones
}

module "auth" {
  source      = "./modules/auth"
  environment = var.environment
}

module "jenkins" {
  source      = "./modules/jenkins"
  vpc_id      = module.networking.vpc_id
  subnet_id   = module.networking.public_subnets_id[0]
  environment = var.environment
  key_name    = module.auth.key_name
  local_ip    = var.local_ip
  vpc         = module.networking.vpc
}