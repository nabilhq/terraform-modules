resource "aws_route" "egress_wildcard" {
  route_table_id         = var.priv_subnet_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  instance_id            = aws_instance.ec2.id
}