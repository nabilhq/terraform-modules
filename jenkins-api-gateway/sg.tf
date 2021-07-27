resource "aws_security_group" "main" {
  name        = "lambda-${var.vpc_name}-${var.service_name}"
  description = "grants agress access for  ${var.vpc_name}-${var.service_name} lambda"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_security_group_rule" "github_webhook_forwarder_egress_wildcard" {
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = -1
  source_security_group_id = var.jenkins_source_sg_id
  security_group_id        = aws_security_group.main.id
}