resource "aws_secretsmanager_secret" "jenkins_prod_api_credential" {
  name                    = "jenkins-prod-api-credentials"
  description             = "jenkins prod api creds"
  recovery_window_in_days = 0

  tags = {
    Name        = "jenkins-prod-api-credentials"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_prod_api_credential" {
  secret_id = aws_secretsmanager_secret.jenkins_prod_api_credential.id

  secret_string = <<SECRET
{
  "username": "${var.jenkins_api_username}",
  "token": "${var.jenkins_prod_api_token}"
}
SECRET
}

resource "aws_secretsmanager_secret" "jenkins_staging_api_credential" {
  name                    = "jenkins-staging-api-credentials"
  description             = "jenkins staging api creds"
  recovery_window_in_days = 0

  tags = {
    Name        = "jenkins-staging-api-credentials"
    Service     = var.service_name
    Environment = "staging"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_staging_api_credential" {
  secret_id = aws_secretsmanager_secret.jenkins_staging_api_credential.id

  secret_string = <<SECRET
{
  "username": "${var.jenkins_api_username}",
  "token": "${var.jenkins_staging_api_token}"
}
SECRET
}