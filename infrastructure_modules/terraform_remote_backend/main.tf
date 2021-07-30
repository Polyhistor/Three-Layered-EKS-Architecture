# used to append random integer to S3 bucket to avoid conflicting bucket name across the globe
resource "random_integer" "digits" {
  min = 1
  max = 100

  keepers = {
    # Generate a new integer each time s3_bucket_name value gets updated
    listener_arn = var.app_name
  }
}

module "s3_bucket_terraform_remote_backend" {
  source = "../../resource_modules/storage/s3"

  bucket        = local.bucket_name
  acl           = var.acl
  policy        = data.aws_iam_policy_document.bucket_policy.json
  tags          = local.tags
  force_destroy = var.force_destroy

  website                              = local.website
  cors_rule                            = local.cors_rule
  versioning                           = local.versioning
  logging                              = local.logging
  lifecycle_rule                       = local.lifecycle_rule
  replication_configuration            = local.replication_configuration
  server_side_encryption_configuration = local.server_side_encryption_configuration
  object_lock_configuration            = local.object_lock_configuration

  ## s3 bucket public access block ##
  block_public_policy     = var.block_public_policy
  block_public_acls       = var.block_public_acls
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}

########################################
## Dynamodb for TF state locking
########################################
module "dynamodb_terraform_state_lock" {
  source         = "../../resource_modules/database/dynamodb"
  name           = local.dynamodb_name
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  attribute_name = var.attribute_name
  attribute_type = var.attribute_type
  sse_enabled    = var.sse_enabled
  tags           = var.tags
}

########################################
## KMS
########################################
module "s3_kms_key_terraform_backend" {
  source = "../../resource_modules/identity/kms_key"

  name                    = local.ami_kms_key_name
  description             = local.ami_kms_key_description
  deletion_window_in_days = local.ami_kms_key_deletion_window_in_days
  tags                    = local.ami_kms_key_tags
  policy                  = data.aws_iam_policy_document.s3_terraform_states_kms_key_policy.json
  enable_key_rotation     = true
}