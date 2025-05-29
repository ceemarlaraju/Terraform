
terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}
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
  region = "us-east-1" # Free Tier compatible region
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Generate random password for RDS
resource "random_password" "rds_password" {
  length  = 16
  special = false
}

# Store credentials in Secrets Manager
resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "prod/rds/credentials"
  description = "RDS master credentials"

  recovery_window_in_days = 0 # Immediate deletion (use 7-30 in production)

  tags = {
    ManagedBy = "Terraform"
  }
}

resource "aws_secretsmanager_secret_version" "initial" {
  secret_id = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.rds_password.result
    engine   = "mysql"
  })
}

# Create security group for RDS
resource "aws_security_group" "rds_sg" {
  name        = "rds-security-group"
  description = "Allow access to RDS"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to specific IPs in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "RDS Security Group"
  }
}

# Create RDS instance (Free Tier compatible)
resource "aws_db_instance" "main" {
  identifier             = "free-tier-db"
  allocated_storage      = 20 # Free Tier max
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "8.0.41"         # Free Tier compatible
  instance_class         = "db.t4g.micro" # Free Tier eligible
  db_name                = "freeTierDB"
  username               = "dbadmin"
  password               = random_password.rds_password.result
  skip_final_snapshot    = true # For testing only (set to false in production)
  publicly_accessible    = true # For testing only (set to false in production)
  vpc_security_group_ids = [aws_security_group.rds_sg.id]

  # Free Tier requirements
  backup_retention_period = 0  # Free Tier limit (7 days max for free)
  max_allocated_storage   = 20 # Prevents auto-scaling beyond Free Tier

  tags = {
    Name        = "Free-Tier-RDS"
    Environment = "Test"
  }

  # Prevent accidental deletion
  deletion_protection = false # Set to true in production
}

# Output connection details
output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "secret_arn" {
  value = aws_secretsmanager_secret.rds_credentials.arn
}


resource "aws_instance" "rds_client" {

  instance_type               = "t2.micro"
  ami                         = "ami-0953476d60561c955"
  subnet_id                   = "subnet-0ca4b81bd17393972"
  key_name                    = "terraform-us-key"
  vpc_security_group_ids      = [aws_security_group.rds_sg.id]
  associate_public_ip_address = true


}