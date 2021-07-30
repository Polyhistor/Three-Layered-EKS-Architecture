########################################
# Metadata
########################################
variable "env" {
  description = "The name of the environment."
  type = string
}

variable "app_name" {
  description = "The name of the application."
  type = string
}

variable "region" {
  description = "The AWS region this bucket should reside in."
  type = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type = map
}

########################################
## S3
########################################
variable "acl" {
  description = "The canned ACL to apply."
  type = string
}

variable "force_destroy" {
  description = "A boolean that indicates all objects should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable."
  type = string
}

variable "versioning_enabled" {
  description = "Enable versioning. Once you version-enable a bucket, it can never return to an unversioned state."
  type = string
}

## s3 bucket public access block ##
variable "block_public_policy" {
  description = "Whether Amazon S3 should block public bucket policies for this bucket."
  type = string
}

variable "block_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type = string
}

variable "ignore_public_acls" {
  description = "Whether Amazon S3 should ignore public ACLs for this bucket."
  type = string
}

variable "restrict_public_buckets" {
  description = "Whether Amazon S3 should restrict public bucket policies for this bucket."
  type = string
}

########################################
## DynamoDB
########################################
variable "read_capacity" {
  description = "The number of read units for this table."
  type = string
}

variable "write_capacity" {
  description = "The number of write units for this table."
  type = string
}

variable "hash_key" {
  description = "The attribute to use as the hash (partition) key."
  type = string
}

variable "attribute_name" {}

variable "attribute_type" {}

variable "sse_enabled" {
  description = "Encryption at rest using an AWS managed Customer Master Key. If enabled is false then server-side encryption is set to AWS owned CMK (shown as DEFAULT in the AWS console). If enabled is true then server-side encryption is set to AWS managed CMK (shown as KMS in the AWS console). ."
  type = string
}
