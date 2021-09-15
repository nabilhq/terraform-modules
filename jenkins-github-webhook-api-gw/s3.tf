resource "aws_s3_bucket" "main" {
  bucket = "${var.vpc_name}-${var.service_name}"
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = false
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name        = "${var.vpc_name}-${var.service_name}"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_object" "github_webhook" {
  bucket = aws_s3_bucket.main.id
  key    = "github_webhook.zip"
  source = var.github_webhook_lambda_package_path
}

resource "aws_s3_bucket_object" "github_webhook_authorizer" {
  bucket = aws_s3_bucket.main.id
  key    = "github_webhook_authorizer.zip"
  source = var.github_webhook_authorizer_lambda_package_path
}