resource "aws_route53_record" "prod" {
  zone_id = var.main_domain_zone_id
  name    = "jenkins-it.${var.domain}"
  type    = "A"

  alias {
    name                   = aws_lb.ec2_prod.dns_name
    zone_id                = aws_lb.ec2_prod.zone_id
    evaluate_target_health = true
  }
}