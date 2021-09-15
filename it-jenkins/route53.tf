resource "aws_route53_record" "lb_prod" {
  zone_id = var.main_domain_zone_id
  name    = "${var.service_name}.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ec2_prod.dns_name
    zone_id                = aws_lb.ec2_prod.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "lb_staging" {
  zone_id = var.main_domain_zone_id
  name    = "${var.service_name}-staging.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ec2_staging.dns_name
    zone_id                = aws_lb.ec2_staging.zone_id
    evaluate_target_health = true
  }
}