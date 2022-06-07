resource "aws_instance" "WEB_server8" {
  ami                         = "ami-0f9fc25dd2506cf6d"
  associate_public_ip_address = "true"
  availability_zone           = "us-east-1a"
  subnet_id                   = aws_subnet.public[0].id  
  instance_type               = "t2.micro"
  key_name                    = "myprivate"
  depends_on                  = [aws_s3_bucket.bum, aws_db_instance.db]
  user_data                   = templatefile("user_data2.sh.tpl")


  tags = {
    Name = "WEB8public"
  }

  tags_all = {
    Name = "WEB-server8public"
  }
  vpc_security_group_ids = ["${aws_security_group.webservers.id}"]
}
 
 
