resource "aws_secretsmanager_secret" "admin" {
  name                    = "${var.service_name}-admin-creds"
  description             = "${var.service_name} default admin credentials"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.service_name}-admin-creds"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "admin" {
  secret_id = aws_secretsmanager_secret.admin.id

  secret_string = <<SECRET
{
  "username": "${var.admin_username}",
  "password": "${var.admin_password}"
}
SECRET
}

resource "aws_secretsmanager_secret" "jenkins_yaml_config_params_prod" {
  name                    = "${var.service_name}-jenkins-yaml-config-params-prod"
  description             = "${var.service_name} jenkins.yaml config param values"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.service_name}-jenkins-yaml-config-params-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_yaml_config_params_prod" {
  secret_id = aws_secretsmanager_secret.jenkins_yaml_config_params_prod.id

  secret_string = <<SECRET
{
  "hostname": "${var.service_name}",
  "serviceName": "${var.service_name}",
  "domain": "${var.domain}",
  "adminUsername":"${var.admin_username}",
  "adminEmail":"${var.admin_email}",
  "gitAccount":"${var.github_account}",
  "gitRepo":"${var.github_repo}",
  "gitBranch":"${var.github_branch_prod}",
  "awsRegion":"${var.aws_region}"
}
SECRET
}

resource "aws_secretsmanager_secret" "jenkins_yaml_config_params_staging" {
  name                    = "${var.service_name}-jenkins-yaml-config-params-staging"
  description             = "${var.service_name} jenkins.yaml config param values"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.service_name}-jenkins-yaml-config-params-staging"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_yaml_config_params_staging" {
  secret_id = aws_secretsmanager_secret.jenkins_yaml_config_params_staging.id

  secret_string = <<SECRET
{
  "hostname": "${var.service_name}-staging",
  "serviceName": "${var.service_name}",
  "domain": "${var.domain}",
  "adminUsername":"${var.admin_username}",
  "adminEmail":"${var.admin_email}",
  "gitAccount":"${var.github_account}",
  "gitRepo":"${var.github_repo}",
  "gitBranch":"${var.github_branch_staging}",
  "awsRegion":"${var.aws_region}"
}
SECRET
}

resource "aws_secretsmanager_secret" "jenkins_yaml_config_params_staging" {
  name                    = "${var.service_name}-jenkins-yaml-config-params-prod"
  description             = "${var.service_name} jenkins.yaml config param values"
  recovery_window_in_days = 0

  tags = {
    Name        = "${var.service_name}-jenkins-yaml-config-params-prod"
    Service     = var.service_name
    Environment = "prod"
    Terraform   = true
  }
}

resource "aws_secretsmanager_secret_version" "jenkins_yaml_config_params_staging" {
  secret_id = aws_secretsmanager_secret.jenkins_yaml_config_params_staging.id

  secret_string = <<SECRET
{
  "hostname": "${var.service_name}-staging",
  "serviceName": "${var.service_name}",
  "domain": "${var.domain}",
  "adminUsername":"${var.admin_username}",
  "adminEmail":"${var.admin_email}",
  "gitAccount":"${var.github_account}",
  "gitRepo":"${var.github_repo}",
  "gitBranch":"${var.github_branch_staging}",
  "awsRegion":"${var.aws_region}"
}
SECRET
}

resource "aws_secretsmanager_secret" "github_at" {
  name                    = "${var.service_name}-github-at"
  description             = "github access token"
  recovery_window_in_days = 0

  tags = {
    Name                       = "${var.service_name}-github-at"
    Service                    = var.service_name
    Environment                = "prod"
    Terraform                  = true
    "jenkins:credentials:type" = "string"
  }
}

resource "aws_secretsmanager_secret_version" "github_at" {
  secret_id     = aws_secretsmanager_secret.github_at.id
  secret_string = var.github_access_token
}

resource "aws_secretsmanager_secret" "github_creds" {
  name                    = "${var.service_name}-github-creds"
  description             = "github user credentials"
  recovery_window_in_days = 0

  tags = {
    Name                           = "${var.service_name}-github-creds"
    Service                        = var.service_name
    Environment                    = "prod"
    Terraform                      = true
    "jenkins:credentials:type"     = "usernamePassword"
    "jenkins:credentials:username" = var.github_username
  }
}

resource "aws_secretsmanager_secret_version" "github_creds" {
  secret_id     = aws_secretsmanager_secret.github_creds.id
  secret_string = var.github_access_token
}

resource "aws_secretsmanager_secret" "github_webhook_shared_secret" {
  name                    = "${var.service_name}-github-webhook-shared-secret"
  description             = "github webhook shared secret"
  recovery_window_in_days = 0

  tags = {
    Name                       = "${var.service_name}-github-webhook-shared-secret"
    Service                    = var.service_name
    Environment                = "prod"
    Terraform                  = true
    "jenkins:credentials:type" = "string"
  }
}

resource "aws_secretsmanager_secret_version" "github_webhook_shared_secret" {
  secret_id     = aws_secretsmanager_secret.github_webhook_shared_secret.id
  secret_string = var.github_webhook_shared_secret
}

resource "aws_secretsmanager_secret" "prod_ol_read_client_creds" {
  name                    = "${var.service_name}-prod-ol-api-client-creds-read"
  description             = "onelogin prod api client credentials - read all"
  recovery_window_in_days = 0

  tags = {
    Name                           = "${var.service_name}-prod-ol-api-client-creds-read"
    Service                        = var.service_name
    Environment                    = "prod"
    Terraform                      = true
    "jenkins:credentials:type"     = "usernamePassword"
    "jenkins:credentials:username" = var.prod_ol_read_client_id
  }
}

resource "aws_secretsmanager_secret_version" "prod_ol_read_client_creds" {
  secret_id     = aws_secretsmanager_secret.prod_ol_read_client_creds.id
  secret_string = var.prod_ol_read_client_secret
}

resource "aws_secretsmanager_secret" "prod_ol_manage_all_client_creds" {
  name                    = "${var.service_name}-prod-ol-api-client-creds-manage-all"
  description             = "onelogin prod api client credentials - manage all"
  recovery_window_in_days = 0

  tags = {
    Name                           = "${var.service_name}-prod-ol-api-client-creds-manage-all"
    Service                        = var.service_name
    Environment                    = "prod"
    Terraform                      = true
    "jenkins:credentials:type"     = "usernamePassword"
    "jenkins:credentials:username" = var.prod_ol_manage_all_client_id
  }
}

resource "aws_secretsmanager_secret_version" "prod_ol_manage_all_client_creds" {
  secret_id     = aws_secretsmanager_secret.prod_ol_manage_all_client_creds.id
  secret_string = var.prod_ol_manage_all_client_secret
}

resource "aws_secretsmanager_secret" "prod_ol_manage_all_access_token" {
  name                    = "${var.service_name}-prod-ol-api-access-token-manage-all"
  description             = "onelogin prod api access token - manage all"
  recovery_window_in_days = 0

  tags = {
    Name                       = "${var.service_name}-prod-ol-api-access-token-manage-all"
    Service                    = var.service_name
    Environment                = "prod"
    Terraform                  = true
    "jenkins:credentials:type" = "string"
  }
}

resource "aws_secretsmanager_secret" "prod_ol_read_access_token" {
  name                    = "${var.service_name}-prod-ol-api-access-token-read"
  description             = "onelogin prod api access token - read"
  recovery_window_in_days = 0

  tags = {
    Name                       = "${var.service_name}-prod-ol-api-access-token-read"
    Service                    = var.service_name
    Environment                = "prod"
    Terraform                  = true
    "jenkins:credentials:type" = "string"
  }
}