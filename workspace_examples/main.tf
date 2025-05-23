terraform {
  backend "s3" {

    bucket = "workspace-bucket-terraform-33"
    region = "ap-south-1"
    key    = "workerspce-state.tf"

  }
}

provider "aws" {

  region = var.aws_region
}


resource "aws_vpc" "worksp-demo" {

  cidr_block           = var.cidr_address
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "vpc-${terraform.workspace}"
  }

}

resource "aws_internet_gateway" "wk-igw" {

  vpc_id = aws_vpc.worksp-demo.id

  tags = {
    Name = "wk_igw-${terraform.workspace}"
  }
  depends_on = [aws_vpc.worksp-demo]
}

data "aws_availability_zones" "available" {
  state = "available"
}
resource "aws_subnet" "wk-public-subnet" {

  vpc_id                  = aws_vpc.worksp-demo.id
  cidr_block              = var.public-subnet-1
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "subnet-${terraform.workspace}"

  }
  depends_on = [aws_vpc.worksp-demo]

}

resource "aws_subnet" "wk-public-subnet-2" {

  vpc_id                  = aws_vpc.worksp-demo.id
  cidr_block              = var.public-subnet-2
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "subnet2-${terraform.workspace}"
  }
  depends_on = [aws_subnet.wk-public-subnet]

}


resource "aws_route_table" "wk-route-table" {

  vpc_id = aws_vpc.worksp-demo.id


  route {
    cidr_block = var.route-cidr_address
    gateway_id = aws_internet_gateway.wk-igw.id
  }
  tags = {
    Name    = "route_table-${terraform.workspace}"
    service = "Terraform"
  }
  depends_on = [aws_internet_gateway.wk-igw]
}

resource "aws_route_table_association" "wk-rt-association" {

  subnet_id      = aws_subnet.wk-public-subnet.id
  route_table_id = aws_route_table.wk-route-table.id

}


resource "aws_route_table_association" "wk-rt-association-2" {

  subnet_id      = aws_subnet.wk-public-subnet-2.id
  route_table_id = aws_route_table.wk-route-table.id

}

resource "aws_security_group" "wk-sg" {
  name        = var.sg_name
  description = "allow all traffic"
  vpc_id      = aws_vpc.worksp-demo.id

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
    Name = "secg-${terraform.workspace}"
  }
  depends_on = [aws_vpc.worksp-demo]
}


resource "aws_instance" "server" {

  instance_type               = var.instance_type
  ami                         = var.ami_id
  vpc_security_group_ids      = [aws_security_group.wk-sg.id]
  subnet_id                   = aws_subnet.wk-public-subnet.id
  associate_public_ip_address = true
  key_name                    = var.key_name

  tags = {
    Name = "server-${terraform.workspace}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

