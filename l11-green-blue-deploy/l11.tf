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
  dynamic "ingress" { #dynamic block creation for ingress connection
    for_each = var.allow_ports_server
    content {
      description = "Dynamic ingress port open"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"] #from anywhere
    }
  }
  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.10.0.0/16"] #from internal
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Webserver-SG"
  }
}
#-------------security group for load_balancer-------------
resource "aws_security_group" "for_load_balancer" {
  name        = "group_for_balancer"
  description = "balancer SG"
  dynamic "ingress" { #dynamic block creation for ingress connection
    for_each = var.allow_ports_balancer
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
  tags = {
    Name = "LoadBalancer-SG"
  }
}
#--------------launch configuration vs dynamic(prefix) name---------------------
resource "aws_launch_configuration" "web" {
  name_prefix     = "Launch_conf-"
  image_id        = data.aws_ami.latest_amazon_linux.id
  instance_type   = var.instance_type
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
  name                 = "ASG-for-${aws_launch_configuration.web.name}" #depends on the name of aws_launch_configuration
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2
  max_size             = 2
  min_elb_capacity     = 2
  vpc_zone_identifier  = [aws_default_subnet.default_az0.id, aws_default_subnet.default_az1.id]
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.web_elb.name]
  dynamic "tag" {
    for_each = {
      #   tag.key = "tag.value" << how to create tags in circle
      Name    = "ASG-Web-Server"
      Owner   = "avvppro"
      Project = "testing"
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
  name               = "web-servers-elb"
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  security_groups    = [aws_security_group.for_load_balancer.id]
  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "Web-servers-ELB"
  }
}
#------Default subnets  for web servers in 2 zones------------------------------
resource "aws_default_subnet" "default_az0" {
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "Default subnet for zone 0"
  }
}
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "Default subnet for zone 1"
  }
}
#-----------Load balancer url for domain creation ------------------------------
output "web_elb_url" {
  value = aws_elb.web_elb.dns_name
}
