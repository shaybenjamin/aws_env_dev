
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

variable "prometheus_sg" {
  default = "default"
  description = "Prometheus sg for monitoring"
}

variable "host_os" {
  type    = string
  default = "linux"
}

variable "JENKINS_ADMIN_ID" {
  description = "JENKINS_ADMIN_ID"
}

variable "JENKINS_ADMIN_PASSWORD" {
  description = "JENKINS_ADMIN_PASSWORD"
}


