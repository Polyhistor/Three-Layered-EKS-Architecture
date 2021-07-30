## S3 ##
output "s3_terraform_remote_backend_id" {
  description = "The name of the table"
  value       = module.terraform_remote_backend.s3_id
}

output "s3_terraform_remote_backend_arn" {
  description = "The arn of the table"
  value       = module.terraform_remote_backend.s3_arn
}

## DynamoDB ##
output "dynamodb_terraform_state_lock_id" {
  description = "The name of the table"
  value       = module.terraform_remote_backend.dynamodb_id
}

output "dynamodb_terraform_state_lock_arn" {
  description = "The arn of the table"
  value       = module.terraform_remote_backend.dynamodb_arn
}

## KMS key ##
output "s3_kms_terraform_backend_arn" {
  description = "The Amazon Resource Name (ARN) of the key."
  value       = module.terraform_remote_backend.s3_kms_arn
}

output "s3_kms_terraform_backend_alias_arn" {
  description = "The Amazon Resource Name (ARN) of the key alias."
  value       = module.terraform_remote_backend.s3_kms_alias_arn
}

output "s3_kms_terraform_backend_id" {
  description = "The globally unique identifier for the key."
  value       = module.terraform_remote_backend.s3_kms_id
}
