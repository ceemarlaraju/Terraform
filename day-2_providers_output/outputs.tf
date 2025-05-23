output "instance_id" {
  value = aws_instance.terraform_test.id
}

output "public_ip" {
value = aws_instance.terraform_test.public_ip
  
}