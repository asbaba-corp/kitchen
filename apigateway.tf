
module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"
  create_api_domain_name           = false  # to control creation of API Gateway Domain Name

  name          = "cataprato-http"
  description   = "Cataprato asbaba corporations HTTP"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }


  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"


   default_route_settings = {
    detailed_metrics_enabled = true
    throttling_burst_limit   = 100
    throttling_rate_limit    = 100
  }
   

   
  body = templatefile("apis.yml", {
      authentication = data.aws_lambda_function.authentication.invoke_arn,
      core = data.aws_lambda_function.core.invoke_arn,
      authorizer = data.aws_lambda_function.authorizer.invoke_arn
    })
 
   tags = {
    Deployment = "terraform"
  }
}


data "aws_lambda_function" "authentication" {
  function_name     = "authentication"

}

data "aws_lambda_function" "core" {
  function_name     = "core"
}

data "aws_lambda_function" "authorizer" {
  function_name     = "authorizer"
}

resource "aws_cloudwatch_log_group" "logs" {
  name = "apigateway-logs"
}
