resource "aws_s3_bucket" "main" {
  bucket = "${var.vpc_name}-${var.service_name}-resources"
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
    Name      = "${var.vpc_name}-${var.service_name}"
    Service   = var.service_name
    Terraform = true
  }
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  restrict_public_buckets = true
  ignore_public_acls      = true
}

resource "aws_s3_bucket_object" "job_resources_prod" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "job_resources_prod/"
  source = "/dev/null"
}

resource "aws_s3_bucket_object" "job_resources_staging" {
  bucket = aws_s3_bucket.main.id
  acl    = "private"
  key    = "job_resources_staging/"
  source = "/dev/null"
}