resource "aws_security_group" "allow_elk_sg" {
  name        = "${var.environment}_allow_elk_sg"
  description = "Default security group to allow inbound/outbound to elk stack"
  vpc_id      = "${var.vpc.id}"
  depends_on  = [var.vpc]
  
 

  # elasticsearch port
  ingress {
    from_port       = 9200
    to_port         = 9200
    protocol        = "tcp"
    self            = true
    #security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
    #cidr_blocks = ["${var.local_ip}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # kibana port
  ingress {
    from_port       = 5601
    to_port         = 5601
    protocol        = "tcp"
    self            = true
    #security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
    #cidr_blocks = ["${var.local_ip}"]
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  # logstash port
  ingress {
    from_port       = 5043
    to_port         = 5044
    protocol        = "tcp"
    self            = true
    #security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
    #cidr_blocks = ["${var.local_ip}"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SSH access
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    self            = true
    #security_groups = [aws_security_group.jenkins_master_sg.id, var.prometheus_sg.id]
    #cidr_blocks = ["${var.local_ip}"]
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

resource "aws_security_group" "file_beat_sg" {
  name        = "${var.environment}_file_beat_sg"
  description = "Default security group to allow inbound/outbound to filebeat stack"
  vpc_id      = "${var.vpc.id}"
  depends_on  = [var.vpc]
  
 

  # elasticsearch port
  ingress {
   from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
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