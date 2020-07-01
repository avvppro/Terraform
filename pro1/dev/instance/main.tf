provider "aws" {
  region = data.terraform_remote_state.global_vars.outputs.region
}

terraform { // terraform_remote_state  bucket
  backend "s3" {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "pro1/dev/instance/terraform.tfstate"
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
data "terraform_remote_state" "security_group" { // data from pro1/dev/global_vars for sg creation
  backend = "s3"
  config = {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "pro1/dev/security_group/terraform.tfstate"
    region = "eu-central-1"
  }
}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "inst1" {
  ami                         = data.aws_ami.latest_amazon_linux.id
  instance_type               = "t2.micro"
  security_groups             = [data.terraform_remote_state.security_group.outputs.sg_id, data.terraform_remote_state.security_group.outputs.sg1_id, data.terraform_remote_state.security_group.outputs.sg2_id]
  subnet_id                   = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  associate_public_ip_address = true
  user_data                   = file("user_data.sh")

}
