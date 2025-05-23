output "instance_public_ip" {
  value = aws_instance.ubuntu_server.public_ip

}

output "intance_id" {
  value = aws_instance.ubuntu_server.id
}