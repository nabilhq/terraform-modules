resource "aws_iam_role" "ec2" {
  name        = "ec2-${var.vpc_name}-${var.service_name}"
  description = "grants the ${var.service_name} ec2 instance access to required aws resources"

  assume_role_policy = <<ROLE
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
ROLE

  tags = {
    Name        = "ec2-${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_iam_instance_profile" "ec2" {
  name = aws_iam_role.ec2.name
  role = aws_iam_role.ec2.name
}

resource "aws_iam_policy" "sm_list_secrets" {
  name        = "sm-${var.vpc_name}-${var.service_name}-list-all"
  path        = "/"
  description = "grants ${var.vpc_name}-${var.service_name} access to list all secrets."

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "secretsmanager:ListSecrets"
            ],
            "Resource": "*"
        }
    ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sm_list_secrets" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.sm_list_secrets.arn
}

resource "aws_iam_policy" "sm_read_write_tagged" {
  name        = "sm-${var.vpc_name}-${var.service_name}-rw"
  path        = "/"
  description = "grants read/write access to all ${var.vpc_name}-${var.service_name} tagged secrets"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue",
        "secretsmanager:DescribeSecret",
        "secretsmanager:ListSecretVersionIds",
        "secretsmanager:UpdateSecret"
      ],
      "Resource": "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.service_name}*",
      "Condition": {
        "StringEquals": {
          "secretsmanager:ResourceTag/Service": "${var.service_name}"
        }
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "sm_read_write_tagged" {
  role       = aws_iam_role.ec2.name
  policy_arn = aws_iam_policy.sm_read_write_tagged.arn
}

resource "aws_iam_policy" "s3_main_rw" {
  name        = "s3-${var.vpc_name}-${var.service_name}-main-rw"
  path        = "/"
  description = "grants ${var.service_name} ec2 read/write access to the ${aws_s3_bucket.main.id} s3 bucket"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.main.arn}",
        "${aws_s3_bucket.main.arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "main" {
  role       = "${aws_iam_role.ec2.name}"
  policy_arn = "${aws_iam_policy.s3_main_rw.arn}"
}