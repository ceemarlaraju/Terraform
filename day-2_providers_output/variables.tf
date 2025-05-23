variable "ami_id" {
  description = "ami_id_of_instance"
  default = "ami-062f0cc54dbfd8ef1"
}

variable "aws_region" {
description = "aws_region_to_be_select"
default = "ap-south-1" 

}

variable "instance_type" {

    description = "select_the_instance_type"
    default = "t2.micro"
  
}