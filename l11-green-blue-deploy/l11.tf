#high aviliability web site
#2 servers + load balancer + auto scaling
#zero downtime + green/blue deployment mode
provider "aws" {
  region = var.region
}
#---------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_ami" "latest_amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
#-------------security group for web servers-------------
resource "aws_security_group" "for_web_server" {
  name        = "group_for_server"
  description = "server SG"
  vpc_id      = aws_vpc.vpc0.id
  dynamic "ingress" { #dynamic block creation for ingress connection
    for_each = lookup(var.allow_ports_server, var.stage)
    content {
      description = "Dynamic ingress port open"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #from anywhere
    }
  }
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "Webserver-SG"))
}
#-------------security group for load_balancer-------------
resource "aws_security_group" "for_load_balancer" {
  name        = "group_for_balancer"
  description = "balancer SG"
  vpc_id      = aws_vpc.vpc0.id
  dynamic "ingress" { #dynamic block creation for ingress connection
    for_each = lookup(var.allow_ports_balancer, var.stage)
    content {
      description = "Dynamic ingress port open"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #from anywhere
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "LoadBalancer-SG"))
}
#--------------launch configuration vs dynamic(prefix) name---------------------
resource "aws_launch_configuration" "web" {
  name_prefix     = "Launch_conf-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = lookup(var.instance_type, var.stage) #different instance types for different stages
  security_groups = [aws_security_group.for_web_server.id]
  user_data       = file("user_data.sh")
  lifecycle {
    create_before_destroy = true
  }
}
#----------------------------------------------------------------------
# after data changes in launch_configuration/autoscaling_group/user_data
# new launch_configuration, autoscaling_group and instance will be createn
# then load_balancer switches to new instances. Old instance, autoscaling_group and launch_configuration will be destroy
resource "aws_autoscaling_group" "web_scale" {
  name                      = "ASG-for-${aws_launch_configuration.web.name}" #depends on the name of aws_launch_configuration
  launch_configuration      = aws_launch_configuration.web.name
  min_size                  = 2
  max_size                  = 2
  min_elb_capacity          = 2
  vpc_zone_identifier       = [aws_subnet.az0.id, aws_subnet.az1.id]
  health_check_type         = "ELB"
  load_balancers            = [aws_elb.web_elb.name]
  wait_for_capacity_timeout = "5m"
  dynamic "tag" {
    for_each = {
      #   tag.key = "tag.value" << how to create tags in circle
      Name        = "ASG-Web-Server"
      Owner       = "${var.common_tags["Owner"]}"
      Project     = "${var.common_tags["Project"]}"
      Environment = "${var.stage}"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
  lifecycle {
    create_before_destroy = true
  }
}
#----------elastic load balancer for work in 2 zones ---------------------------
resource "aws_elb" "web_elb" {
  name = "web-servers-elb"
  # availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups = [aws_security_group.for_load_balancer.id]
  subnets         = [aws_subnet.az0.id, aws_subnet.az1.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    target              = "HTTP:80/"
    interval            = 60
  }
  tags = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "Web-servers-ELB"))
}
#-------------------------------------------------------------------------------
resource "aws_vpc" "vpc0" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpc0.id
  tags   = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "Internet GW for vpc0"))
}
resource "aws_route_table" "route0" {
  vpc_id = aws_vpc.vpc0.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  tags = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "route table custom"))
}
resource "aws_main_route_table_association" "a" {
  vpc_id         = aws_vpc.vpc0.id
  route_table_id = aws_route_table.route0.id
}

resource "aws_subnet" "az0" {
  vpc_id                  = aws_vpc.vpc0.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "My subnet for zone 0"))
}
resource "aws_subnet" "az1" {
  vpc_id                  = aws_vpc.vpc0.id
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags                    = merge(var.common_tags, map("Stage", "${var.stage}"), map("Name", "My subnet for zone 1"))
}
#-----------Load balancer url for domain creation ------------------------------
output "web_elb_url" {
  value = aws_elb.web_elb.dns_name
}
