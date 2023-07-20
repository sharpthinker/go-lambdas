data "archive_file" "certGen" {
  type        = "zip"
  source_file  = "certGen"
  output_path = "certGen.zip"
}

resource "aws_s3_bucket_object" "certGen" {
  bucket = aws_s3_bucket.lambda-golang-archives-eu-central-1.id
  key    = "certGen.zip"
  source = "certGen.zip"
  depends_on =  [aws_s3_bucket.lambda-golang-archives-eu-central-1]
}

resource "aws_lambda_function" "tfer--certGen-eu-central-1" {
  architectures = ["x86_64"]

  environment {
    variables = {
      CA_CERTIFICATE_ARN = "arn:aws:acm:eu-central-1:923553073565:certificate/ed6d3467-3224-4cb0-b9c9-49a98c752c15"
      CA_KEY_ARN         = "arn:aws:secretsmanager:eu-central-1:923553073565:secret:ca/encryptedPrivKey-eP5NZt"
    }
  }

  ephemeral_storage {
    size = "512"
  }
  s3_bucket                      = aws_s3_bucket.lambda-golang-archives-eu-central-1.id
  s3_key                         = aws_s3_bucket_object.certGen.key
  function_name                  = "certGen-eu-central-1"
  handler                        = "certGen"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::923553073565:role/certGen-eu-central-1-Lambda"
  runtime                        = "go1.x"
  skip_destroy                   = "false"
  source_code_hash               = data.archive_file.certGen.output_base64sha256
  timeout                        = "15"

  tracing_config {
    mode = "PassThrough"
  }
  depends_on = [ aws_s3_bucket.lambda-golang-archives-eu-central-1 ]
}
