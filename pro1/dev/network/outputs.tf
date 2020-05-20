#=======================Dev=================================
output "region"
value = var.region
output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids // using from /modules/aws_network/outputs.tf file
}
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "env" {
  value = module.vpc.env
}
output "vpc_cidr" {
  value = module.vpc.cidr_block
}
output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}
