provider "aws" {
  region = var.region_name
}

data "aws_vpc" "default_vpc" {

  id = "vpc-0e7fc91ef2705c8aa"
}

data "aws_subnet" "az_1" {

  id = "subnet-0bb50a5c65b5b5a70"

}

data "aws_security_group" "sg_name" {

  id = "sg-0662e050faa31fb64"

}

resource "aws_instance" "server" {

  instance_type               = var.instance_type
  ami                         = var.ami_id
  key_name                    = var.key_name
  subnet_id                   = data.aws_subnet.az_1.id
  vpc_security_group_ids      = [data.aws_security_group.sg_name.id]
  associate_public_ip_address = true

  tags = {
    Name = "server"
  }

  lifecycle {
    prevent_destroy = false
  }
}
