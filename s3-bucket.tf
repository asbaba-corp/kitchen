module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "3.14.1" 

  bucket = "balcony-frontend"
  website = {
    index_document = "index.html"
    error_document = "error.html"
  }

  expected_bucket_owner = data.aws_caller_identity.current.account_id
  control_object_ownership = true
  object_ownership         = "BucketOwnerPreferred"

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  attach_policy           = true

   policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "PublicReadGetObject",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "s3:GetObject",
      "Resource": "arn:aws:s3:::balcony-frontend/*"
    }
  ]
}
POLICY
}

data "aws_caller_identity" "current" {}
