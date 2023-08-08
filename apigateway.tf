terraform {
 required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.9.0"
    }
  }
  cloud {
    organization = "Cataprato"

    workspaces {
      name = "cataprato-kitchen"
    }
  }
}

module "api_gateway" {
  source = "terraform-aws-modules/apigateway-v2/aws"

  name          = "cataprato-http"
  description   = "My awesome HTTP API Gateway"
  protocol_type = "HTTP"

  cors_configuration = {
    allow_headers = ["content-type", "x-amz-date", "authorization", "x-api-key", "x-amz-security-token", "x-amz-user-agent"]
    allow_methods = ["*"]
    allow_origins = ["*"]
  }


  # Access logs
  default_stage_access_log_destination_arn = aws_cloudwatch_log_group.logs.arn
  default_stage_access_log_format          = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId $context.integrationErrorMessage"

  # Routes and integrations
  for_each = data.aws_lambda_functions.all.function_arns

  integrations = {

    "$default" = {
      lambda_arn = each.key
    }
 
  }

  tags = {
    Name = "http-apigateway"
  }
}

data "aws_lambda_functions" "all" {}

resource "aws_cloudwatch_log_group" "logs" {
  name = "apigateway-logs"
}