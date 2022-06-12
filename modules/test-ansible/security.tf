# resource "aws_security_group" "jenkins_master_sg" {
#    name        = "${var.environment}_jenkins_master_sg"
#    description = "Default security group to allow inbound/outbound from the VPC"
#    vpc_id      = "${var.vpc.id}"
#    depends_on  = [var.vpc]
  

#   ingress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["${var.local_ip}"]
#     //security_groups = [var.prometheus_sg.id]
#   }

#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     self        = true
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Environment = "${var.environment}"
#   }
# }

resource "aws_security_group" "jenkins_agent_sg_test" {
  name        = "${var.environment}_jenkins_agent_sg_test"
  description = "Default security group to allow inbound/outbound to jenkins agents"
  vpc_id      = "${var.vpc.id}"
  depends_on  = [var.vpc]
  
 

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
    //security_groups = [aws_security_group.jenkins_master_sg.id]
    //security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
    //cidr_blocks = ["${var.local_ip}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }
}