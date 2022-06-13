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

sudo amazon-linux-extras install epel -y
sudo yum install python-pip -y
sudo yum install nginx -y
sudo systemctl enable nginx.service
sudo systemctl start nginx.service
sudo systemctl status nginx.service


#sudo /etc/init.d/nginx start

FILEBEAT_VERSION=8.2.2
FILEBEAT_BASE_VERSION=8.2.2
sudo su

sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch

echo "[elastic-8.x]
name=Elastic repository for 8.x packages
baseurl=https://artifacts.elastic.co/packages/8.x/yum
gpgcheck=1
gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
enabled=1
autorefresh=1
type=rpm-md" > /etc/yum.repos.d/elastic.repo

sudo yum install filebeat -y
sudo systemctl enable filebeat
sudo chkconfig --add filebeat

#sudo rm /var/log/nginx/access.log /var/log/nginx/error.log

#sudo rm /etc/filebeat/filebeat.yml

echo "output:
  logstash:
    enabled: true
    hosts:
      - ${elkHost}:5044
    timeout: 15
    ssl:
      certificate_authorities:
      - /etc/pki/tls/certs/logstash-beats.crt

filebeat:
  inputs:
    -
      paths:
        - /var/log/syslog
        - /var/log/auth.log
      document_type: syslog
    -
      paths:
        - \"/var/log/nginx/*.log\"
      fields_under_root: true
      fields:
        type: nginx-access" > /etc/filebeat/filebeat.yml

chmod 644 /etc/filebeat/filebeat.yml


mkdir -p /etc/pki/tls/certs
echo "-----BEGIN CERTIFICATE-----
MIIC6zCCAdOgAwIBAgIJANPZwuf+5wTLMA0GCSqGSIb3DQEBCwUAMAwxCjAIBgNV
BAMMASowHhcNMTUxMjI4MTA0NTMyWhcNMjUxMjI1MTA0NTMyWjAMMQowCAYDVQQD
DAEqMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp+jHFvhyYKiPXc7k
0c33f2QV+1hHNyW/uwcJbp5jG82cuQ41v70Z1+b2veBW4sUlDY3yAIEOPSUD8ASt
9m72CAo4xlwYKDvm/Sa3KJtDk0NrQiz6PPyBUFsY+Bj3xn6Nz1RW5YaP+Q1Hjnks
PEyQu4vLgfTSGYBHLD4gvs8wDWY7aaKf8DfuP7Ov74Qlj2GOxnmiDEF4tirlko0r
qQcvBgujCqA7rNoG+QDmkn3VrxtX8mKF72bxQ7USCyoxD4cWV2mU2HD2Maed3KHj
KAvDAzSyBMjI+qi9IlPN5MR7rVqUV0VlSKXBVPct6NG7x4WRwnoKjTXnr3CRADD0
4uvbQQIDAQABo1AwTjAdBgNVHQ4EFgQUVFurgDwdcgnCYxszc0dWMWhB3DswHwYD
VR0jBBgwFoAUVFurgDwdcgnCYxszc0dWMWhB3DswDAYDVR0TBAUwAwEB/zANBgkq
hkiG9w0BAQsFAAOCAQEAaLSytepMb5LXzOPr9OiuZjTk21a2C84k96f4uqGqKV/s
okTTKD0NdeY/IUIINMq4/ERiqn6YDgPgHIYvQheWqnJ8ir69ODcYCpsMXIPau1ow
T8c108BEHqBMEjkOQ5LrEjyvLa/29qJ5JsSSiULHvS917nVgY6xhcnRZ0AhuJkiI
ARKXwpO5tqJi6BtgzX/3VDSOgVZbvX1uX51Fe9gWwPDgipnYaE/t9TGzJEhKwSah
kNr+7RM+Glsv9rx1KcWcx4xxY3basG3/KwvsGAFPvk5tXbZ780VuNFTTZw7q3p8O
Gk1zQUBOie0naS0afype5qFMPp586SF/2xAeb68gLg==
-----END CERTIFICATE-----" > /etc/pki/tls/certs/logstash-beats.crt

filebeat export template --es.version ${FILEBEAT_BASE_VERSION} > /etc/filebeat/filebeat.template.json

filebeat export template --es.version "8.2.2" > /etc/filebeat/filebeat.template.json

touch /usr/local/bin/start.sh

cat << EOF >> /usr/local/bin/start.sh
curl -XPUT -H \"Content-Type: application/json\" 'http://${elkHost}:9200/_template/filebeat?pretty' -d@/etc/filebeat/filebeat.template.json
/etc/init.d/filebeat start
nginx
tail -f /var/log/nginx/access.log -f /var/log/nginx/error.log
EOF

chmod +x /usr/local/bin/start.sh
/usr/local/bin/start.sh



