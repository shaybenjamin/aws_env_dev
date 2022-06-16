resource "aws_instance" "jenkins_master" {
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.jenkins_master_sg.id]
  subnet_id = var.subnet_id[0]
  depends_on = [
    aws_instance.jenkins_agent
  ]

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


  provisioner "remote-exec" {
    inline = [
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
      "docker run -u 0 --name jenkins --rm -p 8080:8080 -p 50001:50001 -p 50000:50000 -d -v jenkins_home:/var/jenkins_home -v /var/run/docker.sock:/var/run/docker.sock --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password --env JENKINS_AGENT_URL=${aws_instance.jenkins_agent.private_ip} --env JENKINS_URL=${self.private_ip} jenkins:jcasc",
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
  user_data = file("${path.module}/assets/agent/userdata_agent.tpl")
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


  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "mkdir -p /home/ec2-user/node_exporter",
      "sudo amazon-linux-extras install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "id ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      "sudo systemctl status docker.service",
      "sudo sed -i \"/.*ExecStart=.*/c\\ExecStart=/usr/bin/dockerd -H tcp://0.0.0.0:4243 -H unix:///var/run/docker.sock\" /lib/systemd/system/docker.service",
      "sudo systemctl daemon-reload",
      "sudo service docker restart",
      "curl http://localhost:4243/version",
      "curl http://${self.private_ip}:4243/version"
    ]
  }

  provisioner "file" {
    source      = "assets/node_exporter.sh"
    destination = "/home/ec2-user/node_exporter/node_exporter.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user/node_exporter",
      "sudo chmod +x node_exporter.sh",
      "./node_exporter.sh",
    ]
  }
}
