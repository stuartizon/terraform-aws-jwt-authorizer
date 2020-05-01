resource "null_resource" "build" {
  provisioner "local-exec" {
    command     = "npm install && npm run build"
    working_dir = path.module
  }
}

data "archive_file" "jwt_authorizer" {
  type        = "zip"
  source_file = "${path.module}/dist/authorize.js"
  output_path = "${path.module}/dist/authorize.zip"

  depends_on = [null_resource.build]
}

data "aws_iam_policy_document" "jwt_authorizer" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jwt_authorizer" {
  name               = var.name
  assume_role_policy = data.aws_iam_policy_document.jwt_authorizer.json
}

resource "aws_lambda_function" "jwt_authorizer" {
  function_name    = var.name
  filename         = data.archive_file.jwt_authorizer.output_path
  source_code_hash = data.archive_file.jwt_authorizer.output_base64sha256
  role             = aws_iam_role.jwt_authorizer.arn
  handler          = "authorize.handler"
  runtime          = "nodejs12.x"

  environment {
    variables = {
      JWKS_URI     = var.jwks_uri
      TOKEN_ISSUER = var.token_issuer
      AUDIENCE     = var.audience
    }
  }
}
