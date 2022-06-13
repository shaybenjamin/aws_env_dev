resource "aws_instance" "elk" {
  #instance_type          = "${var.instance_type}"
  instance_type          = "t2.large"
  #ami                    = "ami-09d56f8956ab235b3"
  ami                    = data.aws_ami.server_ami.id
  key_name               = "${var.key_name}"
  vpc_security_group_ids = [aws_security_group.allow_elk_sg.id]
  subnet_id              = var.subnet_id[0]
  #user_data              = file("${path.module}/assets/userdata.tpl")
  # root_block_device {
  #   volume_size = 8
  # }

  tags = {
    Name        = "${var.environment}-elk"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      //key_name     = "${var.key_name}"
      identityfile = "~/.ssh/mtckey",
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  connection {
    user        = "ec2-user"
    host        = self.public_ip
    timeout     = "1m"
    private_key = file("~/.ssh/mtckey")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
    ]
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' ${path.root}/modules/ansible/playbooks/elk-config.yaml"
  }


#ansible-playbook -u ec2-user -i '174.129.181.121,' --private-key ~/.ssh/mtckey -e pub_key='~/.ssh/mtckey.pub' modules/ansible/playbooks/elk-config.yaml
# connection {
#     user        = "ec2-user"
#     host        = self.public_ip
#     timeout     = "1m"
#     private_key = file("~/.ssh/mtckey")
#   }


#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "mkdir -p /home/ec2-user/node_exporter",
#     ]
#   }

#   provisioner "file" {
#     source      = "assets/node_exporter.sh"
#     destination = "/home/ec2-user/node_exporter/node_exporter.sh"
#   }

#    provisioner "remote-exec" {
#     inline = [
#       "cd /home/ec2-user/node_exporter",
#       "sudo chmod +x node_exporter.sh",
#       "./node_exporter.sh"
#     ]
#   }
}


resource "aws_instance" "filebeat" {
  instance_type          = "${var.instance_type}"
  //instance_type          = "t2.large"
  #ami                    = "ami-09d56f8956ab235b3"
  ami                    = data.aws_ami.server_ami.id
  key_name               = "${var.key_name}"
  vpc_security_group_ids = [aws_security_group.file_beat_sg.id]
  subnet_id              = var.subnet_id[0]
  depends_on = [
    aws_instance.elk
  ]
  user_data              = templatefile("${path.module}/assets/userdata_filebeat.tpl", {
    elkHost = aws_instance.elk.private_ip,
    FILEBEAT_BASE_VERSION = "8.2.2"
  })
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name        = "${var.environment}-filebeat"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      //key_name     = "${var.key_name}"
      identityfile = "~/.ssh/mtckey",
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

connection {
    user        = "ec2-user"
    host        = self.public_ip
    timeout     = "1m"
    private_key = file("~/.ssh/mtckey")
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y python3",
    ]
  }

  # provisioner "local-exec" {
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' ${path.root}/modules/ansible/playbooks/elk-filebeat-config.yaml --extra-vars=\"elk_server=${aws_instance.elk.private_ip}\""
  # }



# connection {
#     user        = "ec2-user"
#     host        = self.public_ip
#     timeout     = "1m"
#     private_key = file("~/.ssh/mtckey")
#   }


#   provisioner "remote-exec" {
#     inline = [
#       "sudo yum update -y",
#       "mkdir -p /home/ec2-user/node_exporter",
#     ]
#   }

#   provisioner "file" {
#     source      = "assets/node_exporter.sh"
#     destination = "/home/ec2-user/node_exporter/node_exporter.sh"
#   }

#    provisioner "remote-exec" {
#     inline = [
#       "cd /home/ec2-user/node_exporter",
#       "sudo chmod +x node_exporter.sh",
#       "./node_exporter.sh"
#     ]
#   }
}