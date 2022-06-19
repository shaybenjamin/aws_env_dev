#! /bin/bash
# sudo amazon-linux-extras install -y epel
# sudo useradd devops
# echo -e 'devops\ndevops' | sudo passwd devops
# echo 'devops ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/devops
# sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
# sudo systemctl restart sshd.service
# sudo yum install -y python3
# sudo yum install -y vim
# sudo yum install -y ansible
# sudo yum install -y git

echo '[ansible]' >> /home/ec2-user/inventory
echo 'ansible-engine ansible_connection=local' >> /home/ec2-user/inventory
# echo '[nodes]' >> /home/ec2-user/inventory
# echo 'node1 ansible_host=${aws_instance.ansible-nodes[0].private_dns}' >> /home/ec2-user/inventory
# echo '${var.jenkins_agent_ec2_host[0].name} ansible_host=${var.jenkins_agent_ec2_host[0].private_dns}' >> /home/ec2-user/inventory
echo '' >> /home/ec2-user/inventory
echo '[all:vars]' >> /home/ec2-user/inventory
echo 'ansible_user=devops' >> /home/ec2-user/inventory
echo 'ansible_password=devops' >> /home/ec2-user/inventory
echo 'ansible_connection=ssh' >> /home/ec2-user/inventory
echo '#ansible_python_interpreter=/usr/bin/python3' >> /home/ec2-user/inventory
echo 'ansible_ssh_private_key_file=/home/devops/.ssh/id_rsa' >> /home/ec2-user/inventory
echo "ansible_ssh_extra_args=' -o StrictHostKeyChecking=no -o PreferredAuthentications=password '" >> /home/ec2-user/inventory
echo '[defaults]' >> /home/ec2-user/ansible.cfg
echo 'inventory = ./inventory' >> /home/ec2-user/ansible.cfg
echo 'host_key_checking = False' >> /home/ec2-user/ansible.cfg
echo 'remote_user = devops' >> /home/ec2-user/ansible.cfg