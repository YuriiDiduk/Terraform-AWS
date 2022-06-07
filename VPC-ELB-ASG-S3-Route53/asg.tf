#----------------------------------------------aws_launch_configuration-aws_autoscaling_group-------------------------------------




resource "aws_launch_configuration" "there" {
  name_prefix     = "terraform-aws-asg-"
  image_id        = var.webservers_ami
  instance_type   = "t2.micro"
  #user_data       = file("install_httpd2.sh")
  security_groups = [aws_security_group.webservers.id]

  lifecycle {
    create_before_destroy = true
  }
  user_data                   = templatefile("user_data2.sh.tpl", {
    f_name = "${aws_db_instance.db.address}",
    l_name = "DIDUK",
    name   = "${var.access_key}",
    names  = "${var.secret_key}"
  })

  
}


resource "aws_autoscaling_group" "that" {
  min_size             = 1
  max_size             = 4
  desired_capacity     = 2
  launch_configuration = aws_launch_configuration.there.name
  target_group_arns    = ["${aws_lb_target_group.these.arn}"]  
  vpc_zone_identifier  = ["${aws_subnet.private.0.id}", "${aws_subnet.private.1.id}"]
  #target_group_arns   = [data.aws_lb_target_group.these.arn]
}





