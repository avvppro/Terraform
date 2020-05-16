variable "region" {
  default = "eu-central-1"
}
variable "stage" {
  default = "development"
  # default = "testing"
  # default = "staging"
  # default = "production"
}

variable "instance_type" {
  default = {
    "development" = "t2.micro"
    "testing"     = "t3.micro"
    "staging"     = "t2.small"
    "production"  = "t3.small"
  }
}
variable "allow_ports_server" {
  type = map
  default = {
    "development" = ["22", "80", "443"]
    "testing"     = ["22", "80", "443"]
    "staging"     = ["80", "443"]
    "production"  = ["80", "443"]
  }
}
variable "allow_ports_balancer" {
  type = map
  default = {
    "development" = ["80", "443"]
    "testing"     = ["80", "443"]
    "staging"     = ["80", "443"]
    "production"  = ["80", "443"]
  }
}
variable "common_tags" {
  type = map
  default = {
    Owner   = "avvppro"
    Project = "testing"
  }
}
