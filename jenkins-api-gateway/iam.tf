resource "aws_iam_role" "github_webhook_forwarder" {
  name        = "lambda-${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
  description = "role attached to lambda-${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE

  tags = {
    Name        = "lambda-${var.vpc_name}-${var.service_name}-${var.environment}-github-webhook-forwarder"
    Service     = var.service_name
    Environment = var.environment
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "github_webhook_forwarder" {
  role       = aws_iam_role.github_webhook_forwarder.name
  policy_arn = var.lambda_vpc_access_arn
}