#-------------security group http--------------
resource "aws_security_group" "main" {
  name        = "${var.env}-${var.name}"
  description = "server sg"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.allow_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = var.protocol
      cidr_blocks = [var.vpc_cidr]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }
}
