resource "aws_security_group" "webservers" {
  name        = "allow_http"
  description = "Allow http inbound traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80 
    to_port     = 80 
    protocol    = "tcp"
    security_groups = [aws_security_group.ALB.id]
    cidr_blocks = ["0.0.0.0/0"]
    }
    
  ingress {
    from_port   = 443 
    to_port     = 443 
    protocol    = "tcp"
    security_groups = [aws_security_group.ALB.id]
    cidr_blocks = ["0.0.0.0/0"]
    }
    
  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.ALB.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "ALB" {
  name = "learn-asg-terramino-lb"
  dynamic "ingress" {
     for_each = ["80", "443"]
  content{
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
    }
 }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  vpc_id = aws_vpc.main.id
}



#_+_+_+_+_+_+_++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

