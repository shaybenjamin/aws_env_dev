#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
sudo yum update -y
sudo yum install java-1.8.0 -y
sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1 -y
# sudo amazon-linux-extras install -y docker
# sudo usermod -a -G docker ec2-user
# id ec2-user
# sudo systemctl enable docker.service
# sudo systemctl start docker.service
# sudo systemctl status docker.service
sudo docker version

sudo yum install epel-release -y
sudo yum install python-pip -y
sudo pip install awscli
sudo yum install git -y

sudo useradd devops
echo -e 'devops\ndevops' | sudo passwd devops
echo 'devops ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/devops
sudo sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
sudo yum install -y vim
sudo yum install -y ansible
#sudo chmod 777 /var/lib/jenkins/



# docker run -d \
#     --net host \
#     -e JENKINS_URL=http://localhost:8080 \
#     -e JENKINS_AUTH=admin:password  \
#     simenduev/jenkins-auto-slave
    # -v /any/path/you/like:/var/jenkins_home \
