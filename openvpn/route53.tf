resource "aws_route53_record" "lb" {
  zone_id = var.main_domain_zone_id
  name    = "vpn.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ec2.dns_name
    zone_id                = aws_lb.ec2.zone_id
    evaluate_target_health = true
  }
}