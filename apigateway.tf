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
provider "aws" {
  region = "us-east-1"
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_credentials_validation = true
  skip_requesting_account_id  = true
}
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
      auth = data.aws_lambda_function.auth.invoke_arn,
      core = data.aws_lambda_function.core.invoke_arn
    })
 
   tags = {
    Deployment = "terraform"
  }
}

data "aws_lambda_function" "auth" {
  function_name     = "cataprato-auth-lambda"

}

data "aws_lambda_function" "core" {
  function_name     = "cataprato-core-lambda"

}

resource "aws_cloudwatch_log_group" "logs" {
  name = "apigateway-logs"
}
