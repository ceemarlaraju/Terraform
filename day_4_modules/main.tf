provider "aws" {
   region = "ap-south-1" 
}

module "web" {
    source = "./modules/ec2_instance"
    ami_id = "ami-062f0cc54dbfd8ef1"
    instance_type = "t2.micro"
    instance_name = "web_server" 
}