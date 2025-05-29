terraform {
  backend "s3" {

    bucket         = "terraform-state-bucket-2222"
    key            = "test-lock.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true

  }
}


provider "aws" {
  region = "ap-south-1"

}

resource "aws_vpc" "vpc_terraform" {

  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = "true"


  tags = {
    name = "test_vpc"
  }

}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "terra_subnet" {

  vpc_id                  = aws_vpc.vpc_terraform.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    name = "subnet1"
  }

}

resource "aws_subnet" "terra_subnet_2" {

  vpc_id                  = aws_vpc.vpc_terraform.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    name = "subnet2"
  }

}

resource "aws_internet_gateway" "terra-igw" {

  vpc_id = aws_vpc.vpc_terraform.id

  tags = {
    name = "terra-igw"
  }

}


resource "aws_route_table" "public-rt" {

  vpc_id = aws_vpc.vpc_terraform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terra-igw.id
  }
  tags = {
    name    = "public-rt"
    service = "Terraform"
  }
}

resource "aws_route_table_association" "association-Terraform" {
  subnet_id      = aws_subnet.terra_subnet.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table_association" "association-Terraform_1" {
  subnet_id      = aws_subnet.terra_subnet_2.id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_security_group" "terraform-sg" {
  name        = "terraform-sg"
  description = "allow ports for vpc"
  vpc_id      = aws_vpc.vpc_terraform.id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    name = "allow_all"
  }
}

resource "aws_instance" "Redhat_ec2" {
  ami                         = "ami-0402e56c0a7afb78f" # Ubuntu AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.terra_subnet.id
  vpc_security_group_ids      = [aws_security_group.terraform-sg.id]
  key_name                    = "balu_ap-south-1"
  associate_public_ip_address = true

  tags = {
    Name = "redhat-Instance"
  }
}

resource "aws_instance" "terra-server" {
  ami                         = "ami-06031e2c49c278c8f" # Ubuntu AMI
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.terra_subnet_2.id
  vpc_security_group_ids      = [aws_security_group.terraform-sg.id]
  key_name                    = "balu_ap-south-1"
  associate_public_ip_address = true

  tags = {
    Name = "amazon-2-instance"
  }
}

