
variable "access_key" { default = "XXXXXXXXXXXXXXX" }
variable "secret_key" { default = "XXXXXXXXXXXXXXXXXXXXXXXXXXXX" }
variable "region" { default = "us-east-1" }
variable "db_pass" { default = "password123" }
variable "db_user" { default = "root" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "subnet_one_cidr" { default = "10.0.1.0/24" }
variable "subnet_two_cidr" { default = ["10.0.2.0/24", "10.0.3.0/24"] }
variable "route_table_cidr" { default = "0.0.0.0/0" }
variable "host" {default = "aws_instance.my_web_instance.public_dns"}
variable "web_ports" { default = ["22", "80", "443", "3306"] }
variable "db_ports" { default = ["22", "3306"] }
variable "images" {
  type = map
  default = {
    "us-east-1"      = "ami-0ff8a91507f77f867"
  }
}
