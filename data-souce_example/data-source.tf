data "aws_vpc" "data-source" {

  id = "vpc-0e68196763570ff7a"

}

resource "aws_internet_gateway" "data-source-igw" {

  vpc_id = data.aws_vpc.data-source.id

  tags = {
    name = "data-source-igw"
  }

}