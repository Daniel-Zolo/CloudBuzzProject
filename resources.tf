resource "aws_sns_topic" "user_updates" {
  name = "SumSNS"

}
data "aws_sns_topic" "SumSNS" {
  name = "SumSNS"
}

resource "aws_iam_role" "MainZoloSNS" {
  name = "MainZolo-SNS"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "MainZoloSNSPolicy" {
  name        = "MainZolo-SNS-Policy"
  description = "IAM policy for MainZolo-SNS role"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "sns:CreateTopic",
        "sns:ListTopics",
        "sns:SetTopicAttributes",
        "sns:DeleteTopic"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Publish",
      "Resource": "arn:aws:sns:*:069301198269:SumSNS"
    },
    {
      "Effect": "Allow",
      "Action": "sns:Subscribe",
      "Resource": "*",
      "Condition": {
        "StringLike": {
          "aws:SourceArn": "arn:aws:sns:*:069301198269:SumSNS"
        },
        "StringEquals": {
          "aws:SourceOwner": "069301198269"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "MainZoloSNSPolicyAttachment" {
  role       = aws_iam_role.MainZoloSNS.name
  policy_arn = aws_iam_policy.MainZoloSNSPolicy.arn
}


resource "aws_lambda_function" "test_lambda" {
  filename      = "Function.zip"
  function_name = "FunctionLambda"
  role          = aws_iam_role.MainZoloSNS.arn
  handler       = "Function.lambda_handler"
  runtime       = "python3.8"
}

resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = "arn:aws:sns:eu-north-1:069301198269:SumSNS"
  protocol  = "email"
  endpoint  = "daniel.zolo.devops@gmail.com"
}
resource "aws_sns_topic_subscription" "email_subscription2" {
  topic_arn = "arn:aws:sns:eu-north-1:069301198269:SumSNS"
  protocol  = "email"
  endpoint  = "eranz@cloudbuzz.co.il"
}

# resource "aws_apigatewayv2_api" "my_rest_api" {
#   name          = "MyRESTAPI"
#   protocol_type = "HTTP"
#   target        = aws_lambda_function.test_lambda.arn
# }

# resource "aws_lambda_permission" "apigw_lambda_permission" {
#   statement_id  = "AllowAPIGatewayInvoke"
#   action        = "lambda:InvokeFunction"
#   function_name = aws_lambda_function.test_lambda.function_name
#   principal     = "apigateway.amazonaws.com"
# }

# resource "aws_apigatewayv2_integration" "lambda_integration" {
#   api_id               = aws_apigatewayv2_api.my_rest_api.id
#   integration_type     = "AWS_PROXY"
#   integration_uri      = aws_lambda_function.test_lambda.invoke_arn
#   integration_method   = "POST"
#   payload_format_version = "2.0"
# }

# resource "aws_apigatewayv2_route" "lambda_route" {
#   api_id    = aws_apigatewayv2_api.my_rest_api.id
#   route_key = "GET /FunctionLambda/test"

#   target = "integrations/${aws_apigatewayv2_integration.lambda_integration.id}"
# }

# resource "aws_apigatewayv2_stage" "api_stage" {
#   api_id      = aws_apigatewayv2_api.my_rest_api.id
#   name        = "default"
#   auto_deploy = true
# }