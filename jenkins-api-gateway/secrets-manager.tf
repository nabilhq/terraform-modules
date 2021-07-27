resource "aws_secretsmanager_secret" "jenkins_api_credential" {
  name                    = "jenkins-api-credentials"
  description             = "jenkins api creds"
  recovery_window_in_days = 0

  tags = {
    Name        = "jenkins-api-credentials"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_api_credential" {
  secret_id = aws_secretsmanager_secret.jenkins_api_credential.id

  secret_string = <<SECRET
{
  "username": "${var.jenkins_api_username}",
  "token": "${var.jenkins_api_token}"
}
SECRET
}