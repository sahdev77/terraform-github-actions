terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.12.1"
    }
  }
}

provider "aws" {
  region     = "eu-west-1"
  access_key = "AKIAWCB35447ENFKIKHR"
secret_key = "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"
}

resource "aws_iam_role" "this" {
  managed_policy_arns = [
    "arn:aws:iam::416737519422:policy/mube_authencation_lambdas_logs_policy"
  ]

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

# Generates an archive from content, a file, or a directory of files.

data "archive_file" "zip_the_lambda" {
 type        = "zip"
 source_dir  = "${path.module}/python/"
 output_path = "${path.module}/python/auth_lambda_test.zip"
}


# Create a lambda function
# In terraform ${path.module} is the current directory.
resource "aws_lambda_function" "terraform_lambda_func" {
 filename                       = "${path.module}/python/auth_lambda_test.zip"
 function_name                  = "auth_lambda_confirm_forgot_pw"
 role                           = "arn:aws:iam::416737519422:role/mube_authentication_lambda_role"
 handler                        = "lambda_function.lambda_handler"
 runtime                        = "python3.10"
 environment {
    variables = {
      client_id = "i9mf5ov9e7k31ttm44fedokdv"
     client_secret = "ql513tc5o1jtipohla48k1pa632bflqqlptq2caq29h3cd061s9"
      region_name = "eu-west-1"
      user_group_id = "eu-west-1_r1Tb8Zi5m"
    }
  }
}
