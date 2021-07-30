## ECR repo ##
output "arn" {
  description = "Full ARN of the repository."
  value       = aws_ecr_repository.this.arn
}
output "name" {
  description = "The name of the repository."
  value       = aws_ecr_repository.this.name
}
output "registry_id" {
  description = "The registry ID where the repository was created."
  value       = aws_ecr_repository.this.registry_id
}
output "repository_url" {
  description = "The URL of the repository (in the form aws_account_id.dkr.ecr.region.amazonaws.com/repositoryName)."
  value       = aws_ecr_repository.this.repository_url
}

## ECR repo policy ##
output "repo_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = aws_ecr_repository_policy.this.policy
}

## ECR lifecycle policy ##
output "lifecycle_policy" {
  description = "policy - (Required) The policy document. This is a JSON formatted string."
  value       = aws_ecr_lifecycle_policy.this.policy
}