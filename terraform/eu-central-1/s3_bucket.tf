resource "aws_s3_bucket" "lambda-golang-archives-eu-central-1" {
  bucket        = "lambda-golang-archives-eu-central-1"
  force_destroy = "false"

  object_lock_enabled = "false"
  request_payer       = "BucketOwner"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }

      bucket_key_enabled = "true"
    }
  }

  versioning {
    enabled    = "false"
    mfa_delete = "false"
  }
}