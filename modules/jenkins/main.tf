resource "aws_instance" "jenkins_master" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  subnet_id              = var.subnet_id[0]
  

  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "${var.environment}-jenkins_master"
  }

  provisioner "local-exec" {
    //command = templatefile("../../assets/${var.host_os}-ssh-config.tpl", {
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

provisioner "file" {
    source      = "~/.ssh/mtckey"
    destination = "/home/ec2-user/.ssh/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo chmod 600 /home/ec2-user/.ssh/id_rsa",
      "mkdir -p /home/ec2-user/playground/jcasc",
      "mkdir -p /home/ec2-user/node_exporter",
      "sudo yum update -y",
      "sudo yum search docker",
      "sudo yum info docker",
      "sudo amazon-linux-extras install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "id ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      "sudo systemctl status docker.service",
      "sudo docker version",
    ]
  }

  provisioner "file" {
    source      = "modules/jenkins/assets/master/"
    destination = "/home/ec2-user/playground/jcasc"
  }

  

  provisioner "file" {
    source      = "assets/node_exporter.sh"
    destination = "/home/ec2-user/node_exporter/node_exporter.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/playground/jcasc",
      "docker build -t jenkins:jcasc .",
      "docker run -u 0 --name jenkins --rm -p 8080:8080 -p 50001:50001 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JENKINS_ADMIN_ID=${var.JENKINS_ADMIN_ID} --env JENKINS_ADMIN_PASSWORD=${var.JENKINS_ADMIN_PASSWORD} --env JENKINS_URL=${self.private_ip} jenkins:jcasc",
      "cd /home/ec2-user/node_exporter",
      "sudo chmod +x node_exporter.sh",
      "./node_exporter.sh"
    ]
  }
}

resource "aws_instance" "jenkins_agent" {
  instance_type          = var.instance_type
  ami                    = data.aws_ami.server_ami.id
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_agent_sg.id]
  subnet_id              = var.subnet_id[0]
  depends_on = [aws_instance.jenkins_master]
  #user_data = file("${path.module}/assets/agent/userdata_agent.tpl")
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name = "${var.environment}-jenkins_agent"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
      hostname = self.public_ip,
      user     = "ec2-user",
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


  # provisioner "remote-exec" {
  #   inline = [
  #     # "sudo yum update -y",
  #     # "mkdir -p /home/ec2-user/node_exporter",
  #     # "sudo amazon-linux-extras install -y docker",
  #     # "sudo usermod -a -G docker ec2-user",
  #     # "id ec2-user",
  #     # "sudo systemctl enable docker.service",
  #     # "sudo systemctl start docker.service",
  #     # "sudo systemctl status docker.service",

  #     # Expose Dockerhost - replace line in file
  #     # "sudo sed -i \"/.*ExecStart=.*/c\\ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock\" /lib/systemd/system/docker.service",
  #     # "sudo systemctl daemon-reload",
  #     # "sudo service docker restart",
  #     # "curl http://localhost:4243/version",
  #     # "curl http://${self.private_ip}:4243/version"
  #   ]
  # }

  provisioner "file" {
      source      = "~/.ssh/mtckey"
      destination = "/home/ec2-user/.ssh/id_rsa"
  }
  
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/ec2-user/node_exporter",
      "sudo chmod 600 /home/ec2-user/.ssh/id_rsa"
    ]
  }

  provisioner "file" {
    source      = "assets/node_exporter.sh"
    destination = "/home/ec2-user/node_exporter/node_exporter.sh"
  }


  provisioner "local-exec" {
    # command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' -e private_ip=${self.private_ip} -e JENKINS_MASTER_URL=${aws_instance.jenkins_master.private_ip} ${path.root}/modules/ansible/playbooks/jenkins-agent.yaml"
    command = <<-EOT
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${self.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' -e private_ip=${self.private_ip} -e JENKINS_MASTER_URL=${aws_instance.jenkins_master.private_ip} -e USER=${var.JENKINS_ADMIN_ID} -e PASS=${var.JENKINS_ADMIN_PASSWORD} ${path.root}/ansible/playbooks/jenkins-agent.yaml
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -u ec2-user -i '${aws_instance.jenkins_master.public_ip},' --private-key ~/.ssh/mtckey -e 'pub_key=~/.ssh/mtckey.pub' -e private_ip=${self.private_ip} ${path.root}/ansible/playbooks/jenkins-agent-registration.yaml
    EOT
  }

  # provisioner "remote-exec" {
  #   inline = [
  #     # "mkdir -p /home/ec2-user/node_exporter",
  #     "cd /home/ec2-user/node_exporter",
  #     "sudo chmod +x node_exporter.sh",
  #     "./node_exporter.sh",
  #   ]
  # }
}
