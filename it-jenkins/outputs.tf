output "lb_sg_id" {
  value = aws_security_group.lb.id
}

output "prod_ec2_priv_ip" {
  value = aws_instance.ec2_prod.private_ip
}

output "staging_ec2_priv_ip" {
  value = aws_instance.ec2_staging.private_ip
}

output "prod_route53_record_fqdn" {
  value = aws_route53_record.lb_prod.fqdn
}

output "staging_route53_record_fqdn" {
  value = aws_route53_record.lb_staging.fqdn
}