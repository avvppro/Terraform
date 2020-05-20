provider "aws" {
  region = var.region
}

terraform { // terraform_remote_state  bucket
  backend "s3" {
    bucket = "avvppro-terraform.tfstate-bucket"
    key    = "pro1/dev/global_vars/terraform.tfstate"
    region = "eu-central-1"
  }
}
