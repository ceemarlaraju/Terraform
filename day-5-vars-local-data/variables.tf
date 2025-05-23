variable "instance_type" {
  description = "specifying_the_of_ec2_instance"
  type        = string
  default     = "t2.micro"

}
variable "region" {

  description = "region_for_aws_provider"
  type        = string
  default     = "ap-south-1"

}
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

