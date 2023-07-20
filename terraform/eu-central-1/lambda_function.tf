variable "privKeyPass" {
  type = string
  description = "Password for private key encryption/decryption"
}

data "aws_lambda_function" "existing" {
  count         = fileexists("certGen.zip") ? 0 : 1
  function_name = "certGen-eu-central-1"
}

locals {
  source_code_hash = fileexists("certGen.zip") ? filebase64sha256("certGen.zip") : data.aws_lambda_function.existing[0].source_code_hash
}

resource "aws_lambda_function" "tfer--certGen-eu-central-1" {
  architectures = ["x86_64"]

  environment {
    variables = {
      CA_CERTIFICATE_ARN = "arn:aws:acm:eu-central-1:923553073565:certificate/c1042f7d-6ccf-4c7d-8bef-e4ff14f147a3"
      CA_KEY_ARN         = "arn:aws:secretsmanager:eu-central-1:923553073565:secret:ca/encryptedPrivKey-eP5NZt"
      PRIV_KEY_PASS      = var.privKeyPass
    }
  }

  ephemeral_storage {
    size = "512"
  }
  publish = true
  filename = "certGen.zip"
  function_name                  = "certGen-eu-central-1"
  handler                        = "certGen"
  memory_size                    = "512"
  package_type                   = "Zip"
  reserved_concurrent_executions = "-1"
  role                           = "arn:aws:iam::923553073565:role/certGen-eu-central-1-Lambda"
  runtime                        = "go1.x"
  skip_destroy                   = "false"
  source_code_hash               = local.source_code_hash
  timeout                        = "15"

  tracing_config {
    mode = "PassThrough"
  }
}
