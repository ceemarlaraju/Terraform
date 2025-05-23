output "public_ip_redhat" {
  description = "to know the instances ip addresses"
  value       = aws_instance.Redhat_ec2.public_ip


}

output "public_ip_amazon" {
  description = "to know the instances ip addresses"
  value       = aws_instance.terra-server.public_ip


}
output "vpc_id" {

  value = aws_vpc.vpc_terraform.id

}