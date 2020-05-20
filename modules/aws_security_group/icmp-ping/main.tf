#-------------security group icmp-ping--------------
resource "aws_security_group" "main" {
  name        = "${var.env}-${var.name}"
  description = "ping sg"
  vpc_id      = var.vpc_id

  ingress {
    content {
      from_port   = 8
      to_port     = 0
      protocol    = var.protocol
      cidr_blocks = [var.ingress_cidr]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}
