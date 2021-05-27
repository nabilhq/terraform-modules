output "ec2_private_ip" {
  value = aws_instance.ec2.private_ip
}

output "ec2_public_ip" {
  value = aws_instance.ec2.public_ip
}

output "ec2_public_fqdn" {
  value = aws_route53_record.lb.fqdn
}