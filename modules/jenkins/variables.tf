
variable "instance_type" {
  description = "EC2 instace type"
  default = "t2.micro"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "vpc" {
  description = "VPC instace"
}

variable "subnet_id" {
  description = "SubnetId for instance"
}

variable "environment" {
  description = "The Deployment environment"
}

variable "key_name" {
  description = "SSH key name"
}

variable "local_ip" {
  description = "Local IP for ingress"
}

variable "host_os" {
  type    = string
  default = "windows"
}
