resource "aws_security_group" "github_webhook_forwarder" {
  name        = "lambda-${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
  description = "grants agress access for  ${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder lambda"
  vpc_id      = var.vpc_id

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_security_group_rule" "github_webhook_forwarder_egress_wildcard" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.github_webhook_forwarder.id
}