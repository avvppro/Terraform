#=====================Default==================================
/*
output "default_public_subnet_ids" {
  value = module.vpc-default.public_subnet_ids
}

output "default_private_subnet_ids" {
  value = module.vpc-default.private_subnet_ids
}
*/
#=======================Dev=================================

output "dev_public_subnet_ids" {
  value = module.vpc-dev.public_subnet_ids // using module outputs.tf file
}

output "dev_private_subnet_ids" {
  value = module.vpc-dev.private_subnet_ids
}

#========================Test=================================
/*
output "test_public_subnet_ids" {
  value = module.vpc-test.public_subnet_ids
}

output "test_private_subnet_ids" {
  value = module.vpc-test.private_subnet_ids
}

#==========================Prod==============================

output "prod_public_subnet_ids" {
  value = module.vpc-prod.public_subnet_ids
}

output "prod_private_subnet_ids" {
  value = module.vpc-prod.private_subnet_ids
}
*/
