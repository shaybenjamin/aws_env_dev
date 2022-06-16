## ================================ Ansible Engine Instance ================================================
resource "aws_instance" "ansible-engine" {
  instance_type = var.instance_type
  ami           = data.aws_ami.server_ami.id
  key_name      = aws_key_pair.ec2loginkey.key_name
  #key_name               = "${var.key_name}"
  subnet_id              = var.subnet_id[0]
  vpc_security_group_ids = [aws_security_group.ansible_access_sg.id]

  # Install Ansible on engine instance
  user_data = "${file("${path.module}/assets/user-data-ansible-engine.sh")}"

  root_block_device {
    volume_size = 8
  }

  provisioner "local-exec" {
    command = templatefile("${path.root}/assets/${var.host_os}-ssh-config.tpl", {
      hostname     = self.public_ip,
      user         = "ec2-user",
      identityfile = "~/.ssh/mtckey",
    })
    interpreter = var.host_os == "windows" ? ["Powershell", "-Command"] : ["bash", "-c"]
  }

  # Create inventory and ansible.cfg on ansible-engine
  provisioner "remote-exec" {
    inline = [
      "echo '[ansible]' >> /home/ec2-user/inventory",
      "echo 'ansible-engine ansible_host=${aws_instance.ansible-engine.private_dns} ansible_connection=local' >> /home/ec2-user/inventory",
      "echo '[nodes]' >> /home/ec2-user/inventory",
      "echo 'node1 ansible_host=${aws_instance.ansible-nodes[0].private_dns}' >> /home/ec2-user/inventory",
      # "echo 'node2 ansible_host=${aws_instance.ansible-nodes[1].private_dns}' >> /home/ec2-user/inventory",
      #  "echo '${var.ansible_hosts[0].name} ansible_host=${var.ansible_hosts[0].private_dns}' >> /home/ec2-user/inventory",
      # "echo '${var.ansible_hosts[1].name} ansible_host=${var.ansible_hosts[1].private_dns}' >> /home/ec2-user/inventory",

      "echo '[jenkins_agents]' >> /home/ec2-user/inventory",
      #"echo 'agent1 ansible_host=${var.ansible_hosts[0].private_dns}' >> /home/ec2-user/inventory",
      "echo '${var.jenkins_agent_ec2_host[0].name} ansible_host=${var.jenkins_agent_ec2_host[0].private_dns}' >> /home/ec2-user/inventory",
      # "echo 'node2 ansible_host=${aws_instance.ansible-nodes[1].private_dns}' >> /home/ec2-user/inventory",
       #"echo '${var.ansible_hosts[0].name} ansible_host=${var.ansible_hosts[0].private_dns}' >> /home/ec2-user/inventory",      
      "echo '' >> /home/ec2-user/inventory",
      "echo '[all:vars]' >> /home/ec2-user/inventory",
      "echo 'ansible_user=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_password=devops' >> /home/ec2-user/inventory",
      "echo 'ansible_connection=ssh' >> /home/ec2-user/inventory",
      "echo '#ansible_python_interpreter=/usr/bin/python3' >> /home/ec2-user/inventory",
      "echo 'ansible_ssh_private_key_file=/home/devops/.ssh/id_rsa' >> /home/ec2-user/inventory",
      "echo \"ansible_ssh_extra_args=' -o StrictHostKeyChecking=no -o PreferredAuthentications=password '\" >> /home/ec2-user/inventory",
      "echo '[defaults]' >> /home/ec2-user/ansible.cfg",
      "echo 'inventory = ./inventory' >> /home/ec2-user/ansible.cfg",
      "echo 'host_key_checking = False' >> /home/ec2-user/ansible.cfg",
      "echo 'remote_user = devops' >> /home/ec2-user/ansible.cfg",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
      agent       = false
    }
  }

  # # copy engine-config.yaml
  # provisioner "file" {
  #   source      = "modules/ansible/playbooks/engine-config.yaml"
  #   destination = "/home/ec2-user/engine-config.yaml"
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file(pathexpand(var.ssh_key_pair))
  #     host        = self.public_ip
  #   }
  # }

  # copy linux_git playbook
  # provisioner "file" {
  #   source      = "modules/ansible/playbooks/linux_git.yaml"
  #   destination = "/home/ec2-user/linux_git.yaml"
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file(pathexpand(var.ssh_key_pair))
  #     host        = self.public_ip
  #   }
  # }

  # copy linux_git playbook
  # provisioner "file" {
  #   source      = "modules/ansible/playbooks/linux_docker.yaml"
  #   destination = "/home/ec2-user/linux_docker.yaml"
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file(pathexpand(var.ssh_key_pair))
  #     host        = self.public_ip
  #   }
  # }

  # # copy linux_git playbook
  # provisioner "file" {
  #   source      = "modules/ansible/playbooks/jenkins-agent.yaml"
  #   destination = "/home/ec2-user/jenkins-agent.yaml"
  #   connection {
  #     type        = "ssh"
  #     user        = "ec2-user"
  #     private_key = file(pathexpand(var.ssh_key_pair))
  #     host        = self.public_ip
  #   }
  # }


  provisioner "file" {
    source      = "modules/ansible/playbooks/"
    destination = "/home/ec2-user/"
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  # Execute Ansible Playbook
  provisioner "remote-exec" {
    inline = [
      "echo '*************** Start engine-config.yaml **********************'",
      "sleep 120; ansible-playbook engine-config.yaml",
      
      "echo '*************** Start jenkins-agent.yaml **********************'",
      "sleep 20; ansible-playbook jenkins-agent.yaml",

      # "echo '*************** Start linux_git.yaml **********************'",
      # "sleep 20; ansible-playbook linux_git.yaml",
      # "echo '*************** Start linux_docker.yaml **********************'",
      # "sleep 20; ansible-playbook linux_docker.yaml",
    ]
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file(pathexpand(var.ssh_key_pair))
      host        = self.public_ip
    }
  }

  tags = {
    Name = "${var.environment}-ansible-engine"
  }
}
