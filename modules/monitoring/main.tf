resource "aws_instance" "prometheus" {
  instance_type          = "${var.instance_type}"
  ami                    = data.aws_ami.server_ami.id
  key_name               = "${var.key_name}"

  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]

  subnet_id              = var.subnet_id[0]
  root_block_device {
    volume_size = 8
  }

  tags = {
    Name        = "${var.environment}-prometheus"
  }
  
  provisioner "local-exec" {
    command = templatefile("/assets/${var.host_os}-ssh-config.tpl", {
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
    source      = "modules/monitoring/assets/prometheus.yml"
    destination = "/home/ec2-user/prometheus.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "cd /home/ec2-user",
      "sudo yum update -y",
      "sudo amazon-linux-extras install -y docker",
      "sudo usermod -a -G docker ec2-user",
      "id ec2-user",
      "sudo systemctl enable docker.service",
      "sudo systemctl start docker.service",
      "sudo systemctl status docker.service",
      "sudo docker version",
      "sudo mkdir /prometheus-data",
      "sudo cp /home/ec2-user/prometheus.yml /prometheus-data/.",
      "sudo sed -i 's;<access_key>;${aws_iam_access_key.prometheus_access_key.id};g' /prometheus-data/prometheus.yml",
      "sudo sed -i 's;<secret_key>;${aws_iam_access_key.prometheus_access_key.secret};g' /prometheus-data/prometheus.yml",
      "sudo docker run -d -p 9090:9090 --name=prometheus -v /prometheus-data/prometheus.yml:/etc/prometheus/prometheus.yml prom/prometheus",
      "sudo docker run -d -p 3000:3000 --name=grafana grafana/grafana"
    ]
  }
}