

provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region     = "${var.region}"
}
## get AZ's details
data "aws_availability_zones" "availability_zones" {}
## create VPC
resource "aws_vpc" "myvpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  tags = {
    Name = "myvpc"
  }
}
## create public subnet
resource "aws_subnet" "myvpc_public_subnet" {
  vpc_id                  = "${aws_vpc.myvpc.id}"
  cidr_block              = "${var.subnet_one_cidr}"
  availability_zone       = "${data.aws_availability_zones.availability_zones.names[0]}"
  map_public_ip_on_launch = true
  tags = {
    Name = "myvpc_public_subnet"
  }
}


## create private subnet one
resource "aws_subnet" "myvpc_private_subnet_one" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  cidr_block        = "${element(var.subnet_two_cidr, 0)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[0]}"
  tags = {
    Name = "myvpc_private_subnet_one"
  }
}
# create private subnet two
resource "aws_subnet" "myvpc_private_subnet_two" {
  vpc_id            = "${aws_vpc.myvpc.id}"
  cidr_block        = "${element(var.subnet_two_cidr, 1)}"
  availability_zone = "${data.aws_availability_zones.availability_zones.names[1]}"
  tags = {
    Name = "myvpc_private_subnet_two"
  }
}
## create internet gateway
resource "aws_internet_gateway" "myvpc_internet_gateway" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags=  {
    Name = "myvpc_internet_gateway"
  }
}
## create public route table (assosiated with internet gateway)
resource "aws_route_table" "myvpc_public_subnet_route_table" {
  vpc_id = "${aws_vpc.myvpc.id}"
  route {
    cidr_block = "${var.route_table_cidr}"
    gateway_id = "${aws_internet_gateway.myvpc_internet_gateway.id}"
  }
  tags = {
    Name = "myvpc_public_subnet_route_table"
  }
}
## create private subnet route table
resource "aws_route_table" "myvpc_private_subnet_route_table" {
  vpc_id = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "myvpc_private_subnet_route_table"
  }
}
## create default route table
resource "aws_default_route_table" "myvpc_main_route_table" {
  default_route_table_id = "${aws_vpc.myvpc.default_route_table_id}"
  tags = {
    Name = "myvpc_main_route_table"
  }
}
## associate public subnet with public route table
resource "aws_route_table_association" "myvpc_public_subnet_route_table" {
  subnet_id      = "${aws_subnet.myvpc_public_subnet.id}"
  route_table_id = "${aws_route_table.myvpc_public_subnet_route_table.id}"
}
## associate private subnets with private route table
resource "aws_route_table_association" "myvpc_private_subnet_one_route_table_assosiation" {
  subnet_id      = "${aws_subnet.myvpc_private_subnet_one.id}"
  route_table_id = "${aws_route_table.myvpc_private_subnet_route_table.id}"
}
resource "aws_route_table_association" "myvpc_private_subnet_two_route_table_assosiation" {
  subnet_id      = "${aws_subnet.myvpc_private_subnet_two.id}"
  route_table_id = "${aws_route_table.myvpc_private_subnet_route_table.id}"
}
## create security group for web
resource "aws_security_group" "web_security_group" {
  name        = "web_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "myvpc_web_security_group"
  }
}
## create security group ingress rule for web
resource "aws_security_group_rule" "web_ingress" {
  count             = "${length(var.web_ports)}"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.web_ports, count.index)}"
  to_port           = "${element(var.web_ports, count.index)}"
  security_group_id = "${aws_security_group.web_security_group.id}"
}
## create security group egress rule for web
resource "aws_security_group_rule" "web_egress" {
  count             = "${length(var.web_ports)}"
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.web_ports, count.index)}"
  to_port           = "${element(var.web_ports, count.index)}"
  security_group_id = "${aws_security_group.web_security_group.id}"
}
## create security group for db
resource "aws_security_group" "db_security_group" {
  name        = "db_security_group"
  description = "Allow all inbound traffic"
  vpc_id      = "${aws_vpc.myvpc.id}"
  tags = {
    Name = "myvpc_db_security_group"
  }
}
## create security group ingress rule for db
resource "aws_security_group_rule" "db_ingress" {
  count             = "${length(var.db_ports)}"
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.db_ports, count.index)}"
  to_port           = "${element(var.db_ports, count.index)}"
  security_group_id = "${aws_security_group.db_security_group.id}"
}
## create security group egress rule for db
resource "aws_security_group_rule" "db_egress" {
  count             = "${length(var.db_ports)}"
  type              = "egress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = "${element(var.db_ports, count.index)}"
  to_port           = "${element(var.db_ports, count.index)}"
  security_group_id = "${aws_security_group.db_security_group.id}"
}
  
#----------------------------------------------______________aws_key_pair_________________=======++++++++++++++++++++++++


resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"       # Create a "myKey" to AWS!!
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" { 
    command = "echo '${tls_private_key.pk.private_key_pem}' > /home/paragon/Documents/LAMP/role/myKey.pem"
  }
}

#-----------------------------------------------------EC2---------------------------------------------------------


resource "aws_instance" "WEB_server11" {
  ami                         = "ami-0f9fc25dd2506cf6d"
  associate_public_ip_address = "true"
  availability_zone           = "us-east-1a"
  subnet_id                   = "${aws_subnet.myvpc_public_subnet.id}"   
  instance_type               = "t2.micro"
  iam_instance_profile        = "${aws_iam_instance_profile.test_profile.name}"
  key_name                    = "myKey"
  depends_on                  = [aws_s3_bucket.bum, aws_db_instance.my_database_instance, aws_key_pair.kp]
  user_data                   = templatefile("user_data3.sh.tpl", {
    f_name = "${aws_db_instance.my_database_instance.address}",
    name   = "${var.access_key}",
    names  = "${var.secret_key}"
  })

  tags = {
    Name = "WEB11public"
  }

 
  tags_all = {
    Name = "WEB-server11public"
  }
  vpc_security_group_ids = ["${aws_security_group.web_security_group.id}"]
}
 
   

resource "null_resource" "example_provisioner2" {
  
  depends_on = [aws_instance.WEB_server11]
  
 
  provisioner "remote-exec" { 
       inline = [ 
                  #"sudo su",
                  #"mv /tmp/.my.cnf ~",
                  #"cd /var/www/html/database/",
                  "mysql -u ${var.db_user} -p${var.db_pass} -h ${aws_db_instance.my_database_instance.address} < script.sql",
                  "sudo systemctl restart httpd.service"
       ]

     }
   
  connection {
      type = "ssh"
      user = "ec2-user"
      host = "${aws_instance.WEB_server11.public_dns}"
      password = ""
      #copy <your_private_key>.pem to your local instance home directory
      #restrict permission: chmod 400 <your_private_key>.pem
      private_key = "${file("/home/paragon/Documents/LAMP/role/myKey.pem")}"
}

}

 
resource "aws_db_subnet_group" "my_database_subnet_group3" {
  name       = "mydbsg3"
  subnet_ids = ["${aws_subnet.myvpc_private_subnet_one.id}", "${aws_subnet.myvpc_private_subnet_two.id}"]
  tags = {
    Name = "my_database_subnet_group3"
  }
}


##---------------------------------------------------rds-----------------------------------------------------------



resource "aws_db_instance" "my_database_instance" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t2.micro"
  port                   = 3306
  vpc_security_group_ids = ["${aws_security_group.db_security_group.id}"]
  db_subnet_group_name   = "${aws_db_subnet_group.my_database_subnet_group3.name}"
  db_name                = "php_mysql_crud"
  identifier             = "mysqldb2"
  username               = "root"
  password               = "password123"
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  tags = {
    Name = "my_database_instance"
  }
}

## output webserver and dbserver address

output "db_server_address" {
value = "${aws_db_instance.my_database_instance.address}"
}

output "web_server_address11" {
  value = "${aws_instance.WEB_server11.public_dns}"
}


