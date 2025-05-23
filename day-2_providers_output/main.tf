provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "terraform_test" {
  ami = var.ami_id
  instance_type = var.instance_type
  tags = {
  Name = "test_for_day2"
  }
}