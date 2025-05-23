resource "aws_s3_bucket" "dependon0001testing" {
  bucket = "dependon0001testing"

  tags = {
    name = "dependon0001testing"
  }

  depends_on = [aws_internet_gateway.terra-igw]

}

resource "aws_s3_bucket" "dependon0002testing" {
  bucket = "dependon0002testing"

  tags = {
    name = "dependon0002testing"
  }
  depends_on = [aws_s3_bucket.dependon0001testing]
}

resource "aws_s3_bucket" "dependon0003testing" {
  bucket = "dependon0003testing"

  tags = {
    name = "dependon0003testing"
  }
  depends_on = [aws_s3_bucket.dependon0002testing]
}