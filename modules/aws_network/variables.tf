#default variables-list
variable "vpc_cidr" {
  default = "10.2.0.0/16"
}

variable "env" {
  default = "dev"
}

variable "public_subnet_cidrs" {
  default = [
    "10.2.1.0/24",
    //"10.2.2.0/24",
    //"10.2.3.0/24"
  ]
}

variable "private_subnet_cidrs" {
  default = [
    "10.2.11.0/24",
    "10.2.22.0/24",
    //"10.2.33.0/24"

  ]
}
