# v1.0
# VPC + IGW
# public subnets + route tables
# Nat gateways + elastic ips
# private subnets + route tables
data "aws_availability_zones" "available" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}-igw"
  }
}

#-------------Public Subnets and Routing----------------------------------------
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs) //subnet count = var.cidrs count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)            //ex. element(["a", "b", "c"], 2) = c
  availability_zone       = data.aws_availability_zones.available.names[count.index] // count.index >> 1 by 1 use in order (use all zones)
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}-public-${count.index + 1}" //ex. dev-public-1
  }
}


resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}-route-public-subnets"
  }
}

resource "aws_route_table_association" "public_routes" {   // associate route vs all public subnet
  count          = length(aws_subnet.public_subnets[*].id) // subnet count = associations count
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index) //[*] means all
}


#-----NAT Gateways with Elastic IPs for Private Subnets--------------------------


resource "aws_eip" "nat" {
  count = length(var.private_subnet_cidrs) // 1 elastic ip for every priv subnet
  vpc   = true                             //elastic ip inside vpc?
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat" {
  count         = length(var.private_subnet_cidrs)                      // 1 nat for every priv subnet
  allocation_id = aws_eip.nat[count.index].id                           // allocate ip for nat gateway
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index) // associate at public subnet
  tags = {
    Name = "${var.env}-nat-gw-${count.index + 1}"
  }
}


#--------------Private Subnets and Routing-------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = {
    Name = "${var.env}-private-${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" { //new route table for every single subnet
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat[count.index].id // attach 1 gateway from list
  }
  tags = {
    Name = "${var.env}-route-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}
