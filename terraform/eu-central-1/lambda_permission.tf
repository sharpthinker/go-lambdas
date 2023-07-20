resource "aws_lambda_permission" "tfer--470d332d-9613-5fc1-85cc-3b9135f0a010" {
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:eu-central-1:923553073565:function:certGen-eu-central-1"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:eu-central-1:923553073565:mafob7l5t2/*/*/certgen"
  statement_id  = "470d332d-9613-5fc1-85cc-3b9135f0a010"
}
