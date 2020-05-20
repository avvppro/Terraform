provider "aws" {
  region = data.terraform_remote_state.network.outputs.region
}

terraform { // terraform_remote_state  bucket
  backend "s3" {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "modules/aws_security_group/tcp/terraform.tfstate"
    region = "eu-central-1"
  }
}
data "terraform_remote_state" "network" { // data from pro1/dev/network for sg creation
  backend = "s3"
  config = {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "pro1/dev/network/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "sg" { // overrides variables set in /modules/aws_security_group/tcp/variables.tf directory
  source      = "../../../modules/aws_security_group/tcp/"
  env         = "dev"
  name        = "sg"
  protocol    = "tcp"
  allow_ports = ["80", "443"]
  vpc_cidr    = data.terraform_remote_state.network.outputs.vpc_cidr
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}

module "sg1" { // overrides variables set in /modules/aws_security_group/tcp/variables.tf directory
  source      = "../../../modules/aws_security_group/tcp/"
  env         = "dev"
  name        = "sg1"
  protocol    = "tcp"
  allow_ports = ["22"]
  vpc_cidr    = data.terraform_remote_state.network.outputs.vpc_cidr
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}
