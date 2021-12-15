output "arn" {
  description   = "The full arn of the repository"
  value         = aws_ecr_repository.ecr_repository.arn
}

output "name" {
  description   = "The name of the repository"
  value         = aws_ecr_repository.ecr_repository.name
}

output "registry_id" {
  description   = "The registry ID where the repository was created"
  value         = aws_ecr_repository.ecr_repository.registry_id
}

output "repository_url" {
  description   = "The URL of the repository"
  value         = aws_ecr_repository.ecr_repository.repository_url
}