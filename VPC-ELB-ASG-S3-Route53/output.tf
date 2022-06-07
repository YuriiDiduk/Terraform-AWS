
output "db_server_address" {
value = "${aws_db_instance.db.address}"
}



output "elb_dns_name" {
  value = aws_lb.this.dns_name
}


data "aws_subnets" "exam" {
  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }
}
 
data "aws_lb" "this" {
depends_on = [aws_lb.this]
}
output "aws_lb" {
  value = data.aws_lb.this.arn
}



data "aws_lb_target_group" "these" {
  name = aws_lb_target_group.these.name
}

output "target_group_arn" {
  value = data.aws_lb_target_group.these.arn
}


#________________________________________________________route_53__________________________________________-------------------------------------------

data "aws_elb_hosted_zone_id" "main" {}

output "data_zone_id" {
  value = data.aws_elb_hosted_zone_id.main.id
}

output "elb_dns_id" {
  value = data.aws_elb_hosted_zone_id.main.id
}


data "aws_route53_zone" "selected" {
  name         = "cmcloudlab674.info"
  private_zone = false
}
output "aws_route53_zone_name" {
  value = data.aws_route53_zone.selected.name
}

output "aws_route53_zone" {
  value = data.aws_route53_zone.selected.zone_id
}

output "aws_route53_record_name" {
  value = aws_route53_record.aws.name
}

















 



