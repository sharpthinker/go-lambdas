data "aws_lambda_function" "existing" {
  count         = fileexists("certGen.zip") ? 0 : 1
  function_name = "certGen-us-east-1"
}

locals {
  source_code_hash = fileexists("certGen.zip") ? filebase64sha256("certGen.zip") : data.aws_lambda_function.existing[0].source_code_hash
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
  publish = true
  filename = "certGen.zip"
  function_name                  = "certGen-us-east-1"
  handler                        = "certGen"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::923553073565:role/certGen-us-east-1-Lambda"
  runtime                        = "go1.x"
  skip_destroy                   = "false"
  timeout                        = "15"
  source_code_hash = local.source_code_hash

  tracing_config {
    mode = "PassThrough"
  }
}
