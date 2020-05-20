provider "aws" {
  region = data.terraform_remote_state.global_vars.outputs.region
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
data "terraform_remote_state" "global_vars" { // data from pro1/dev/global_vars for sg creation
  backend = "s3"
  config = {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "pro1/dev/global_vars/terraform.tfstate"
    region = "eu-central-1"
  }
}

module "sg" { // overrides variables set in /modules/aws_security_group/tcp/variables.tf directory
  // source      = "../../../modules/aws_security_group/tcp/"
  source      = "git@github.com:avvppro/terraform.git//modules/aws_security_group/tcp"
  env         = "dev"
  name        = "sg"
  protocol    = "tcp"
  allow_ports = ["80", "443"]
  vpc_cidr    = "0.0.0.0/0" //for internet access
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}

module "sg1" { // overrides variables set in /modules/aws_security_group/tcp/variables.tf directory
  // source      = "../../../modules/aws_security_group/tcp/"
  source      = "git@github.com:avvppro/terraform.git//modules/aws_security_group/tcp"
  env         = "dev"
  name        = "sg1"
  protocol    = "tcp"
  allow_ports = ["22"]
  vpc_cidr    = data.terraform_remote_state.network.outputs.vpc_cidr // access from internal
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id
}
