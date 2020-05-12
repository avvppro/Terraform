variable "region" {
  default = "eu-central-1"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "allow_ports_server" {
  type    = list
  default = ["80", "443"]
}
variable "allow_ports_balancer" {
  type    = list
  default = ["80", "443"]
}
variable "common_tags" {
  type = map
  default = {
    Owner       = "avvppro"
    Project     = "testing"
    Environment = "development"
  }
}
