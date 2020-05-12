output "instance_ip_addr" {
  value = aws_instance.my_web_server.public_ip
}
output "aws_security_group_arn" {
  value = "aws_security_group.for_web_server.arn"
}
