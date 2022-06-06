variable "instance_type" {
  description = "EC2 instace type"
  default = "t2.micro"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "subnet_id" {
  description = "SubnetId for instance"
}

variable "environment" {
  description = "The Deployment environment"
}


# variable "aws_ami_id" {
#   ## Amazon Linux 2 AMI (HVM)
#   default = "ami-02f26adf094f51167"
#   ## "ami-0cd31be676780afa7"
# }

variable "ssh_key_pair" {
  #default = "~/.ssh/id_rsa"
  default = "~/.ssh/mtckey"
  #default = "~/.ssh/id_rsa_ansilble_lab"
}

variable "ssh_key_pair_pub" {
  #default = "~/.ssh/id_rsa.pub"
  default = "~/.ssh/mtckey.pub"
  #default = "~/.ssh/id_rsa_ansilble_lab.pub"
}

variable "ansible_node_count" {
  default = 2
}

variable "host_os" {
  type    = string
  default = "windows"
}

# variable "ansible_hosts" {
#   type        = list(any)
#   # default = [ {name='', private_dns=''},{name='', private_dns=''} ]
#   description = "Ansible hosts to configure"
# }