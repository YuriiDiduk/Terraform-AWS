
#-------------------------------------------------------------------------------------aws_route53_record

resource "aws_route53_record" "aws" {
  zone_id = data.aws_route53_zone.selected.zone_id
  name    = "aws.${data.aws_route53_zone.selected.name}"
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = data.aws_elb_hosted_zone_id.main.id
    evaluate_target_health = true
  }
}



#-----------------------------------------------aws_acm_certificate-------------------------------------------------------
 


resource "aws_acm_certificate" "aws_cmcloudlab674" {
  domain_name               = "cmcloudlab674.info"
  subject_alternative_names = ["*.cmcloudlab674.info"]
  validation_method         = "DNS"
}
 
 
resource "aws_route53_record" "aws_cmcloudlab674_validation" {
  for_each = {
    for dvo in aws_acm_certificate.aws_cmcloudlab674.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  zone_id = data.aws_route53_zone.selected.zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = 60
  records = [
    each.value.record,
  ]

  allow_overwrite = true
} 

resource "aws_acm_certificate_validation" "aws_cmcloudlab674" {
  certificate_arn         = aws_acm_certificate.aws_cmcloudlab674.arn
  validation_record_fqdns = [for record in aws_route53_record.aws_cmcloudlab674_validation : record.fqdn]
} 


