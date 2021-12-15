output "arn" {
  description   = "Full ARN of the repository"
  value         = module.ecr.arn
}

output "name" {
  description   = "The name of the repository"
  value         = module.ecr.name
}

output "registry_id" {
  description   = "The registry ID where the repository was created ."
  value         = module.ecr.registry_id
}

output "repository_url" {
  description   = "The URL of the repository"
  value         = module.ecr.repository_url
}

output "authorization_token" {
  description = "temporary IAM authentication credentials to access the ECR repository encoded in base64"
  value = data.aws_ecr_authorization_token.token.authorization_token
  sensitive = true
}

output "expires_at" {
  description = "The time in UTC RFC3339 format when the authorization token expires"
  value = data.aws_ecr_authorization_token.token.expires_at
}

output "region_id" {
  description = "The Region of the authorization token"
  value = data.aws_ecr_authorization_token.token.id
}

output "passord" {
  description = "The Password decoded from the authorization token"
  value = data.aws_ecr_authorization_token.token.password
  sensitive = true
}

output "proxy_endpoint" {
  description = "The registry URL to use in the docker login command"
  value = data.aws_ecr_authorization_token.token.proxy_endpoint
}

output "username" {
  description = "The User name decoded from the authorization token"
  value = data.aws_ecr_authorization_token.token.user_name
}