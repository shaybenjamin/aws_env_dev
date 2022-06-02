resource "aws_security_group" "prometheus_sg" {
   name        = "${var.environment}_prometheus_sg"
   description = "Default security group to allow inbound/outbound from the VPC"
   vpc_id      = "${var.vpc.id}"
   depends_on  = [var.vpc]
  

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["${var.local_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group" "grafana_sg" {
  name        = "${var.environment}_grafana_sg"
  description = "Default security group to allow inbound/outbound to grafana"
  vpc_id      = "${var.vpc.id}"
  depends_on  = [var.vpc]
  
 

  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    self            = true
    security_groups = [aws_security_group.prometheus_sg.id]
    cidr_blocks = ["${var.local_ip}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }
}