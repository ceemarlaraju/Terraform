provider "aws" {

  region = var.region_name


}

resource "aws_vpc" "demo" {

  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "demo"
  }
}

resource "aws_subnet" "public-subnet" {
  vpc_id                  = aws_vpc.demo.id
  cidr_block              = var.subnet_address
  map_public_ip_on_launch = true
  availability_zone       = var.az

  tags = {
    Name = "public-subnet"
  }

}

resource "aws_internet_gateway" "demo-igw" {

  vpc_id = aws_vpc.demo.id

  tags = {
    Name = "demo-igw"
  }

}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.demo.id


  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.demo-igw.id
  }

  tags = {
    Name = "public-rt"
  }

}

resource "aws_security_group" "demo-sg" {

  vpc_id = aws_vpc.demo.id

  ingress {

    from_port   = "22"
    to_port     = "22"
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "tcp"

  }

  egress {

    from_port   = "0"
    to_port     = "0"
    cidr_blocks = ["0.0.0.0/0"]
    protocol    = "-1"

  }

  tags = {
    Name = "demo-sg"
  }

}

resource "aws_route_table_association" "name" {

  route_table_id = aws_route_table.public-rt.id
  subnet_id      = aws_subnet.public-subnet.id


}

resource "aws_instance" "server" {

  instance_type               = var.instance-type
  ami                         = var.ami-id
  subnet_id                   = aws_subnet.public-subnet.id
  vpc_security_group_ids      = [aws_security_group.demo-sg.id]
  associate_public_ip_address = true
  key_name                    = var.key-name

  tags = {
    Name = "server"
  }


}