data "archive_file" "certGen" {
  type        = "zip"
  source_file  = "certGen"
  output_path = "certGen.zip"
}

resource "aws_s3_bucket_object" "certGen" {
  bucket = aws_s3_bucket.tfer--lambda-golang-archives-us-east-1.id
  key    = "certGen.zip"
  source = "certGen.zip"
  depends_on = [ aws_s3_bucket.tfer--lambda-golang-archives-us-east-1 ]
}

resource "aws_lambda_function" "certGen-us-east-1" {
  architectures = ["x86_64"]

  environment {
    variables = {
      CA_CERTIFICATE_ARN = "arn:aws:acm:us-east-1:923553073565:certificate/97ab6b6b-1409-4690-85ea-7be2c6947d92"
      CA_KEY_ARN         = "arn:aws:secretsmanager:us-east-1:923553073565:secret:ca/encryptedPrivKey-2HtGva"
    }
  }

  ephemeral_storage {
    size = "512"
  }
  s3_bucket = aws_s3_bucket.tfer--lambda-golang-archives-us-east-1.id
  s3_key = aws_s3_bucket_object.certGen.key
  function_name                  = "certGen-us-east-1"
  handler                        = "certGen"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::923553073565:role/certGen-us-east-1-Lambda"
  runtime                        = "go1.x"
  skip_destroy                   = "false"
  timeout                        = "15"
  source_code_hash = data.archive_file.certGen.output_base64sha256

  tracing_config {
    mode = "PassThrough"
  }
  depends_on = [ aws_s3_bucket.tfer--lambda-golang-archives-us-east-1 ]
}
