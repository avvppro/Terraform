provider "aws" {
  region = "eu-central-1"
}
resource "aws_eip" "static_ip" { #create elastic ip and attach it to instance. use with create_before_destroy for same ip at new server
  instance = aws_instance.my_web_server.id
}

resource "aws_instance" "my_web_server" {
  ami           = "ami-076431be05aaf8080"
  instance_type = "t2.micro"
  tags = {
    Name    = "web server"
    Owner   = "avvppro"
    Project = "training"
  }
  vpc_security_group_ids = [aws_security_group.for_web_server.id]
  user_data = templatefile("./script.tpl", {
    site_name = "saitik"
    site_ver  = "v3"
    names     = ["r1", "r2", "r3"]
  })
}
/*lifecycle {
    prevent_destroy = true # no permission for kill server when run "terraform apply/destroy"
    ignore_changes = ["ami","user_data"] # ignore changes in defined blocks when run "terraform apply"
    create_before_destroy = true # kills old instance only when new instance already running.(almost zero down time > переключає швидше ніж обновляється система і запускається сайт через user_data)
}
*/

resource "aws_security_group" "for_web_server" {
  name        = "group_for_server"
  description = "Dynamic security group"
  #vpc_id      = "${aws_vpc.main.id}"

  dynamic "ingress" { #dynamic block ingress creation
    for_each = ["80", "443"]
    content {
      description = "Dynamic ingress port open"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["10.10.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # -1 means any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_80"
  }
}
