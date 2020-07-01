output "instance_id" {
  value = aws_instance.inst1.id
}
output "instance_ip" {
  value = aws_instance.inst1.public_ip
}
