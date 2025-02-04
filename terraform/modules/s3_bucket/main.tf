resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name
  #acl    = "private"
}

output "bucket_arn" {
  value = aws_s3_bucket.my_bucket.arn
}
