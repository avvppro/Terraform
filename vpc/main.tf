provider "aws" {
  region = "eu-central-1"
}

resource "aws_vpc" "vpc1" {
  cidr_block = "10.0.1.0/24"
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.vpc1.id
  cidr_block        = aws_vpc.vpc1.cidr_block
  availability_zone = "eu-central-1a"
  tags = {
    Name = "Main"
  }
}
resource "aws_network_interface" "foo" {
  subnet_id   = aws_subnet.example.id
  private_ips = ["10.0.1.10"]

  tags = {
    Name = "primary_network_interface"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-trusty-14.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  network_interface {
    network_interface_id = aws_network_interface.foo.id
    device_index         = 0
  }


  tags = {
    Name = "HelloWorld"
  }
}
