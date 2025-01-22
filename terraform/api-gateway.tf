
#############################################################
# Criação do API Gateway ocorre nos passos iniciais da infra
# junto com o cluster k8s, pois o deployment da aplicação
# requer que a URL final já esteja disponível para parametrizações
# de webhook.
#
# Integração com o backend ocorre após aplicação rodando, junto aos
# workflows de setup de Autenticação

resource "aws_apigatewayv2_api" "http-api" {
  name          = "http-api"
  protocol_type = "HTTP"
}

output "http-api-url" {
  value = aws_apigatewayv2_api.http-api.api_endpoint
}


## API Deployment

resource "aws_cloudwatch_log_group" "api-gateway-log" {
  name              = "/aws/api-gw/http-api-test-stage"
  retention_in_days = 7
}

resource "aws_apigatewayv2_stage" "http-api-test-stage" {
  api_id      = aws_apigatewayv2_api.http-api.id
  name        = "Test"
  auto_deploy = true

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api-gateway-log.arn
    format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId AuthErr=[$context.authorizer.error] IntegrErr=[$context.integrationErrorMessage] GwErr=[$context.error.message] "
  }
}
