provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"  
  region = "us-east-1"
}

# Main VPC
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  
  tags = {
    Name = "Main-VPC"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  count = length(var.availability_zone)
  cidr_block = "10.0.${count.index}.0/24"
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name = "Public ${element(var.availability_zone, count.index)}"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  count = length(var.availability_zone)
  cidr_block = "10.0.${count.index +2}.0/24"
  availability_zone = element(var.availability_zone, count.index)
  tags = {
    Name = "Private ${element(var.availability_zone, count.index)}"
  }
}

# Main Internal Gateway for VPC
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Main-IGW"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
 
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NAT Gateway EIP"
  }
}

# Main NAT Gateway for VPC
resource "aws_nat_gateway" "nat" {

  allocation_id  = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Main-NAT-Gateway"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

# Association between Public Subnet and Public Route Table
resource "aws_route_table_association" "public" {
  count         = length(aws_subnet.public.*.id)
  subnet_id     = element(aws_subnet.public.*.id,count.index)
  route_table_id = aws_route_table.public.id
}

# Route Table for Private Subnet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "Private Route Table"
  }
}

# Association between Private Subnet and Private Route Table
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private.*.id)
  subnet_id      = element(aws_subnet.private.*.id,count.index)
  route_table_id = aws_route_table.private.id
}

#====================================================================================================================
 
