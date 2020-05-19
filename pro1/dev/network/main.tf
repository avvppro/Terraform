provider "aws" {
  region = var.region
}
#==================================default==================================================
/*module "vpc-default" {
  source = "../../../modules/aws_network"
}*/
#========================================dev================================================
module "vpc-dev" { // overrides variables set in module directory
  source               = "../../../modules/aws_network"
  env                  = "dev"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = []
}
/*
#===================================test=====================================================
module "vpc-test" {
  source               = "../../../modules/aws_network"
  env                  = "staging"
  vpc_cidr             = "10.10.0.0/16"
  public_subnet_cidrs  = ["10.10.1.0/24", "10.10.2.0/24"]
  private_subnet_cidrs = ["10.10.11.0/24", "10.10.22.0/24"]
}
#=====================================prod====================================================
module "vpc-prod" {
  source               = "../../../modules/aws_network"
  env                  = "prod"
  vpc_cidr             = "10.100.0.0/16"
  public_subnet_cidrs  = ["10.100.1.0/24", "10.100.2.0/24", "10.100.3.0/24"]
  private_subnet_cidrs = ["10.100.11.0/24", "10.100.22.0/24", "10.100.33.0/24"]
}
*/
