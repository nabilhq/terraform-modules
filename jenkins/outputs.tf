output "ec2_priv_ip" {
  value = aws_instance.ec2.private_ip
}

output "route53_record_fqdn" {
  value = aws_route53_record.lb.fqdn
}

output "lb_sg_id" {
  value = aws_security_group.lb.id
}