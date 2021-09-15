output "lb_sg_id" {
  value = aws_security_group.lb.id
}

output "prod_ec2_priv_ip" {
  value = aws_instance.ec2_prod.private_ip
}

output "prod_route53_record_fqdn" {
  value = aws_route53_record.lb_prod.fqdn
}

output "github_webhook_secret_arn" {
  value = aws_secretsmanager_secret.github_webhook_shared_secret.arn
}

output "github_webhook_secret_name" {
  value = aws_secretsmanager_secret.github_webhook_shared_secret.name
}

output "staging_route53_record_fqdn" {
  value = aws_route53_record.lb_staging.fqdn
}

output "staging_ec2_priv_ip" {
  value = aws_instance.ec2_staging.private_ip
}