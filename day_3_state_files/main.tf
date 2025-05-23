terraform {
  backend "s3" {
    bucket = "terraform-state-file-raju"
    key = "day_3_state_file/terraform.tfstate"
    region = "ap-south-1"
    dynamodb_table = "terrafrom-lock"
    encrypt = true
  }
}

provider "aws" {

    region = "ap-south-1"
  
}

resource "aws_s3_bucket" "example" {

    bucket = "example-terraform-state-file-raju"

    tags = {
        Environment = "Dev"
    }


  
}