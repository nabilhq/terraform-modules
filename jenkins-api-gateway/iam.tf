resource "aws_iam_role" "main" {
  name        = "lambda-${var.vpc_name}-${var.service_name}"
  description = "role attached to lambda-${var.vpc_name}-${var.service_name}"

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
    Name        = "lambda-${var.vpc_name}-${var.service_name}-"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_iam_role_policy_attachment" "github_webhook_forwarder" {
  role       = aws_iam_role.main.name
  policy_arn = var.lambda_vpc_access_arn
}

resource "aws_iam_policy" "jenkins_api_credential" {
  name        = "sm-${aws_secretsmanager_secret.jenkins_api_credential.name}-r"
  path        = "/"
  description = "grants read access to the ${aws_secretsmanager_secret.jenkins_api_credential.name} secret"

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
            "Resource": "${aws_secretsmanager_secret.jenkins_api_credential.arn}"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "jenkins_api_credential" {
  role       = aws_iam_role.main.name
  policy_arn = aws_iam_policy.jenkins_api_credential.arn
}