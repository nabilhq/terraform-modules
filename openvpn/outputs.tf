output "openvpn_private_ip" {
  value = "${aws_instance.ec2.private_ip}"
}

output "openvpn_public_ip" {
  value = "${aws_instance.ec2.public_ip}"
}

output "openvpn_public_fqdn" {
  value = "${aws_route53_record.lb.fqdn}"
}