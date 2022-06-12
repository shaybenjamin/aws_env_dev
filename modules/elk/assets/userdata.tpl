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
sudo su

sudo amazon-linux-extras install epel -y
sudo yum install python-pip -y

sysctl -w vm.max_map_count=262144
docker pull sebp/elk
docker run -p 5601:5601 -p 9200:9200 -p 5044:5044 -p 9300:9300 -p 9600:9600 -it --name elk sebp/elk

#sudo docker exec -it elk /opt/logstash/bin/logstash --path.data /tmp/logstash/data -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] } }'


#sudo yum install nginx -y
# sudo /etc/init.d/nginx start



