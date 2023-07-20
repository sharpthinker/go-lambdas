resource "aws_lambda_permission" "tfer--fe00e45a-9426-51b9-a997-48f96e2391cd" {
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:us-east-1:923553073565:function:certGen-us-east-1"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:923553073565:kwc3przgqj/*/*/certgen"
  statement_id  = "fe00e45a-9426-51b9-a997-48f96e2391cd"
}
