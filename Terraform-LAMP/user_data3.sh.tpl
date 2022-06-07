#! /bin/bash 
yum update -y
yum install -y httpd
service httpd start
usermod -a -G apache centos
chown -R centos:apache /var/www
yum install -y mysql php php-mysql
systemctl enable httpd.service
cd /var/www/html/
aws s3 cp s3://my34bucket.nameonmetyry/ ./ --recursive
sed -i 's/'db'/'${f_name}'/' db.php
systemctl restart httpd.service
