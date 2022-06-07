#! /bin/bash 
yum update -y
yum install -y httpd
service httpd start
usermod -a -G apache centos
chown -R centos:apache /var/www
systemctl enable httpd.service
 



