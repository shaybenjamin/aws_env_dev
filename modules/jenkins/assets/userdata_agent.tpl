#!/bin/bash
# Use this for your user data (script from top to bottom)
# install httpd (Linux 2 version)
sudo yum update -y
sudo yum install java-1.8.0 -y
sudo alternatives --install /usr/bin/java java /usr/java/latest/bin/java 1 -y
sudo amazon-linux-extras install -y docker
sudo usermod -a -G docker ec2-user
id ec2-user
sudo systemctl enable docker.service
sudo systemctl start docker.service
sudo systemctl status docker.service
sudo docker version

sudo yum install epel-release -y
sudo yum install python-pip -y
sudo pip install awscli
sudo yum install git -y
#sudo chmod 777 /var/lib/jenkins/




