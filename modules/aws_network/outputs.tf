# outputs for use in project outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}
output "env" {
  value = "${var.env}"
}
output "cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}
