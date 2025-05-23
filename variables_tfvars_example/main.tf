terraform {
  backend "s3" {
    bucket  = "terraform-state-bucket-2222"
    key     = "terra_project_state.tf"
    region  = "ap-south-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region_name
}

resource "aws_vpc" "Terra-Project" {
  cidr_block           = var.cidr_address
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = var.vpc_tags
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "public-subnet1" {
  vpc_id                  = aws_vpc.Terra-Project.id
  cidr_block              = var.subnet_address
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = var.subnet1_tag
  }
}

resource "aws_subnet" "public-subnet2" {
  vpc_id                  = aws_vpc.Terra-Project.id
  cidr_block              = var.subnet2_address
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = var.subnet2_tag
  }
}

resource "aws_subnet" "private-subnet" {
  vpc_id                  = aws_vpc.Terra-Project.id
  cidr_block              = var.subnet3_address
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = var.subnet3_tag
  }
}

resource "aws_internet_gateway" "Terra-Project-IGW" {
  vpc_id = aws_vpc.Terra-Project.id

  tags = {
    Name = var.igw_tag
  }
}

resource "aws_eip" "Terra-project-eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "Terra-Project-NAT" {
  allocation_id = aws_eip.Terra-project-eip.id
  subnet_id     = aws_subnet.public-subnet1.id
  depends_on    = [aws_internet_gateway.Terra-Project-IGW]

  tags = {
    Name = var.nat_tag
  }
}

resource "aws_route_table" "Terra-Project-rt-table" {
  vpc_id = aws_vpc.Terra-Project.id

  route {
    cidr_block = var.public_rt_address
    gateway_id = aws_internet_gateway.Terra-Project-IGW.id
  }

  tags = {
    Name    = "public-route"
    service = "Terraform"
  }
}

resource "aws_route_table_association" "public_rt_association" {
  subnet_id      = aws_subnet.public-subnet1.id
  route_table_id = aws_route_table.Terra-Project-rt-table.id
}

resource "aws_route_table_association" "public_rt_association_2" {
  subnet_id      = aws_subnet.public-subnet2.id
  route_table_id = aws_route_table.Terra-Project-rt-table.id
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.Terra-Project.id

  route {
    cidr_block     = var.private_cidr_address
    nat_gateway_id = aws_nat_gateway.Terra-Project-NAT.id
  }

  tags = {
    Name    = var.private_rt_tag
    service = "Terraform"
  }
}

resource "aws_route_table_association" "private_rt_association" {
  subnet_id      = aws_subnet.private-subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_security_group" "Terra-Project-sg" {
  name        = var.sg_name
  description = "allow all traffic"
  vpc_id      = aws_vpc.Terra-Project.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terra-project-sg"
  }
}

resource "aws_instance" "Redhat_ec2" {
  ami                         = var.redhat_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet1.id
  vpc_security_group_ids      = [aws_security_group.Terra-Project-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "redhat-Instance"
  }
}

resource "aws_instance" "terra-server" {
  ami                         = var.amazon_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public-subnet2.id
  vpc_security_group_ids      = [aws_security_group.Terra-Project-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "amazon-2-instance"
  }
}

resource "aws_instance" "Redhat_ec2_private" {
  ami                         = var.ubntu_ami
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.private-subnet.id
  vpc_security_group_ids      = [aws_security_group.Terra-Project-sg.id]
  key_name                    = var.key_name
  associate_public_ip_address = false

  tags = {
    Name = "redhat-Instance_private"
  }
}