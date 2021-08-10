variable "aws_account_id" {
  type        = string
  description = "id of the aws account to work in."
}

variable "availability_zone" {
  type        = string
  description = "aws availability zone to deploy infra to."
}

variable "aws_region" {
  type        = string
  description = "aws region to use."
}

variable "vpc_name" {
  type        = string
  description = "name of the vpc"
}

variable "vpc_id" {
  type        = string
  description = "id of the vpc to deploy in"
}

variable "service_name" {
  type        = string
  description = "name this jenkins service"
}

variable "main_domain_zone_id" {
  type        = string
  description = "id of the main domain zone"
}

variable "domain" {
  type        = string
  description = "domain to use"
}

variable "main_domain_wildcard_cert_validation_arn" {
  type        = string
  description = "wildcard certificate validation arn"
}

variable "ssh_source" {
  type        = string
  description = "source network address to allow ssh to jenkins ec2"
}

variable "web_source" {
  type        = string
  description = "source network address to allow 443 to jenkins ec2"
}

variable "priv_subnet_a_id" {
  type        = string
  description = "id of primary private subnet"
}

variable "priv_subnet_b_id" {
  type        = string
  description = "id of secondary private subnet"
}

variable "domain_wildcard_cert_id" {
  type        = string
  description = "id of the wildcard cert to use"
}

variable "ami_id" {
  type        = string
  description = "id of the ami to deploy."
}

variable "prod_public_key_ssh" {
  type        = string
  description = "public key to add to the prod ec2"
}

variable "prod_private_key_ssh" {
  type        = string
  description = "private key to use to ssh to the prod ec2 instance"
}

variable "prod_ec2_instance_size" {
  type        = string
  description = "size of the prod ec2 instance"
}

variable "prod_ec2_root_volume_size" {
  type        = string
  description = "size of the prod ec2 instance root block device"
}

variable "prod_ec2_root_volume_type" {
  type        = string
  description = "device type of the prod ec2 instance root block device"
}

variable "staging_public_key_ssh" {
  type        = string
  description = "public key to add to the staging ec2"
}

variable "staging_private_key_ssh" {
  type        = string
  description = "private key to use to ssh to the staging ec2 instance"
}

variable "staging_ec2_instance_size" {
  type        = string
  description = "size of the staging ec2 instance"
}

variable "staging_ec2_root_volume_size" {
  type        = string
  description = "size of the staging ec2 instance root block device"
}

variable "staging_ec2_root_volume_type" {
  type        = string
  description = "device type of the staging ec2 instance root block device"
}

variable "admin_email" {
  type        = string
  description = "admin user's email address. used to set the admin address on jenkins"
}

variable "admin_username" {
  type        = string
  description = "username of the admin user. used to create a jenkins admin user"
  default     = null
}

variable "admin_password" {
  type        = string
  description = "password of the admin user. used to create a jenkins admin user"
}

variable "github_webhook_shared_secret" {
  type        = string
  description = "github shared secret used to authenticate webhooks"
}

variable "github_access_token" {
  type        = string
  description = "access token used by the jenkins github plugin to authenticate to github"
}

variable "github_username" {
  type        = string
  description = "username of the user to use to authenticate to github"
  default     = null
}

variable "github_repo" {
  type        = string
  description = "name of the github repo to use for the jenkins.yaml config"
}

variable "github_account" {
  type        = string
  description = "github account to use for the jenkins.yaml config"
}

variable "github_branch_prod" {
  type        = string
  description = "name of the branch to use for the prod jenkins instance"
}

variable "github_branch_staging" {
  type        = string
  description = "name of the branch to use for the staging jenkins instance"
}

variable "jenkins_yaml_config_path" {
  type        = string
  description = "path to the jenkins.yaml config file"
}

variable "jenkins_init_groovy_path" {
  type        = string
  description = "path to the init groovy directory"
}

variable "jenkins_plugins_yaml_path" {
  type        = string
  description = "path to the plugins.yaml file"
}

variable "prod_ol_read_client_id" {
  type        = string
  description = "read only client id of the prod onelogin instance"
}

variable "prod_ol_read_client_secret" {
  type        = string
  description = "read only client secret of the prod onelogin instance"
}

variable "prod_ol_manage_all_client_id" {
  type        = string
  description = "manage all client id of the prod onelogin instance"
}

variable "prod_ol_manage_all_client_secret" {
  type        = string
  description = "manage all client secret of the prod onelogin instance"
}