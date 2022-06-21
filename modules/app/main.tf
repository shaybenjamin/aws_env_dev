
resource "aws_instance" "app" {
  instance_type          = "${var.instance_type}"
  ami                    = data.aws_ami.server_ami.id
  key_name               = "${var.key_name}"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = var.subnet_id[0]
  //user_data              = file("/modules/jenkins/assets/userdata_agent.tpl")
  user_data = "${file("${path.module}/assets/userdata.tpl")}"
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name        = "${var.environment}-app"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
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
  #   command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' ${path.root}/ansible/playbooks/linux_docker.yaml"
  # }

  
}