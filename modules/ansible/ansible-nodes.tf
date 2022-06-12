## ================================ Ansible Node Instances ================================
resource "aws_instance" "ansible-nodes" {
  count           = var.ansible_node_count
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  key_name      = aws_key_pair.ec2loginkey.key_name
  #key_name               = "${var.key_name}"
  subnet_id = var.subnet_id[0]
  vpc_security_group_ids = [aws_security_group.ansible_access_sg.id]
  //user_data       = file("./assets/user-data-ansible-nodes.sh")
  user_data = "${file("${path.module}/assets/user-data-ansible-nodes.sh")}"
  root_block_device {
    volume_size = 8
  }
  
  tags = {
    Name = "${var.environment}-ansible-node-${count.index + 1}"
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
    //command = templatefile("${path.module}/assets/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      identityfile = "~/.ssh/mtckey",
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }
  
}