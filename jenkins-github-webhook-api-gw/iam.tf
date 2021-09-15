resource "aws_iam_role" "api_gw_main" {
  name        = "api-gw-${var.vpc_name}-${var.service_name}"
  description = "role attached to ${var.vpc_name}-${var.service_name}"
  path        = "/"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE

  tags = {
    Name      = "${var.vpc_name}-${var.service_name}"
    Service   = var.service_name
    Terraform = true
  }
}

resource "aws_iam_role_policy" "api_gw_authorizer" {
  name = "${var.service_name}-api-gw-authorizer"
  role = aws_iam_role.api_gw_main.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "lambda:InvokeFunction",
      "Effect": "Allow",
      "Resource": [
        "${aws_lambda_function.github_webhook_api_gw_authorizer.arn}"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_policy" "lambda_authorizer_cloudwatch" {
  name        = "lambda-${var.vpc_name}-${var.service_name}-authorizer-cloudwatch"
  path        = "/"
  description = "policy for logging from lambda authorizers"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role" "lambda_github_webhook_authorizer" {
  name        = "lambda-${var.vpc_name}-${var.service_name}-authorizer"
  description = "role attached to the ${var.vpc_name}-${var.service_name}-authorizer lambda"
  path        = "/"

  assume_role_policy = <<EOF
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
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_github_webhook_authorizer" {
  role       = aws_iam_role.lambda_github_webhook_authorizer.name
  policy_arn = aws_iam_policy.lambda_authorizer_cloudwatch.arn
}

resource "aws_iam_role" "lambda_github_webhook" {
  name        = "lambda-${var.vpc_name}-${var.service_name}"
  description = "role attached to the ${var.vpc_name}-${var.service_name} lambda"
  path        = "/"

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
    Name        = "lambda-${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "lambda_github_webhook" {
  role       = aws_iam_role.lambda_github_webhook.name
  policy_arn = var.lambda_vpc_access_arn
}

resource "aws_iam_policy" "github_webhook_secret" {
  name        = "sm-github-webhook-secret-r"
  path        = "/"
  description = "grants read access to the github webhook secret"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "VisualEditor0",
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds"
      ],
      "Resource": "${var.github_webhook_secret_arn}"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "github_webhook_secret" {
  role       = aws_iam_role.lambda_github_webhook.name
  policy_arn = aws_iam_policy.github_webhook_secret.arn
}