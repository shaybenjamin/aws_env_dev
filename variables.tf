variable "region" {
  description = "us-east-1"
}

variable "environment" {
  description = "The Deployment environment"
}

//Networking
variable "vpc_cidr" {
  description = "The CIDR block of the vpc"
}

variable "public_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the public subnet"
}

variable "private_subnets_cidr" {
  type        = list(any)
  description = "The CIDR block for the private subnet"
}

variable "local_ip" {
  description = "Local IP for ingress"
}

variable "host_os" {
  type    = string
  default = "linux"
}

# variable "playbooks_path" {
#   type    = string
#   default = "${path.root}/modules/ansible/playbooks/"
# }