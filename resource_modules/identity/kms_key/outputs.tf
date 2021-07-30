########################################
# Outputs
########################################

output "arn" {
  description = "The Amazon Resource Name (ARN) of the key."
  value       = aws_kms_key.this.arn
}

output "alias_arn" {
  description = "The Amazon Resource Name (ARN) of the key alias."
  value       = aws_kms_alias.this.arn
}

output "id" {
  description = "The globally unique identifier for the key."
  value       = aws_kms_key.this.id
}
