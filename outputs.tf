output "invoke_arn" {
  value = aws_lambda_function.jwt_authorizer.invoke_arn
}

output "function_name" {
  value = aws_lambda_function.jwt_authorizer.function_name
}