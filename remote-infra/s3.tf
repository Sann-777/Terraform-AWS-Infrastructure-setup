resource "aws_s3_bucket" "remote_s3" {
  bucket = "sann-state-bucket"

  tags = {
    Name = "sann-state-bucket"
  }
}