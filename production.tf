resource "random_id" "random_id_prefix" {
  byte_length = 2
}
/*====
Variables used across all modules
======*/
locals {
  production_availability_zones = ["${var.region}a", "${var.region}b", "${var.region}c"]
  module_path                   = abspath(path.module)
  codebase_root_path            = abspath("${path.module}/../..")
  # Trim local.codebase_root_path and one additional slash from local.module_path
  module_rel_path = substr(local.module_path, length(local.codebase_root_path) + 1, length(local.module_path))
}

module "networking" {
  //source      = "${abspath(path.module)}/modules/networking"
  //source      = "${local.local.module_path}/modules/networking"
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

# module "monitoring" {
#   source      = "./modules/monitoring"
#   vpc_id      = module.networking.vpc_id
#   subnet_id   = module.networking.public_subnets_id[0]
#   environment = var.environment
#   key_name    = module.auth.key_name
#   local_ip    = var.local_ip
#   vpc         = module.networking.vpc
#    host_os = var.host_os
# }

# module "jenkins" {
#   source        = "./modules/jenkins"
#   vpc_id        = module.networking.vpc_id
#   subnet_id     = module.networking.public_subnets_id[0]
#   environment   = var.environment
#   key_name      = module.auth.key_name
#   local_ip      = var.local_ip
#   vpc           = module.networking.vpc
#   //prometheus_sg = module.monitoring.prometheus_sg
#   host_os       = var.host_os
# }


module "test-ansible" {
  source        = "./modules/test-ansible"
  vpc_id        = module.networking.vpc_id
  subnet_id     = module.networking.public_subnets_id[0]
  environment   = var.environment
  key_name      = module.auth.key_name
  local_ip      = var.local_ip
  vpc           = module.networking.vpc
  //prometheus_sg = module.monitoring.prometheus_sg
  host_os       = var.host_os
}

# module "ansible" {
#   //source      = "${local.local.module_path}/modules/ansible"
#   source        = "./modules/ansible"
#   vpc_id        = module.networking.vpc_id
#   subnet_id     = module.networking.public_subnets_id[0]
#   environment   = var.environment
#   host_os       = var.host_os
#   jenkins_agent_ec2_host = [module.jenkins.jenkins_agent_ec2_host[0]]
# }
