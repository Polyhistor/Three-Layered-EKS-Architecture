## ECR repo ##
variable "name" {
  description = "(Required) Name of the repository."
}
variable "image_tag_mutability" {
  description = "(Optional) The tag mutability setting for the repository. Must be one of: MUTABLE or IMMUTABLE. Defaults to MUTABLE."
}
variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
}

## ECR repo policy ##
variable "ecr_repo_policy" {
  description = "(Required) The policy document. This is a JSON formatted string."
}

## ECR lifecycle policy ##
variable "ecr_lifecycle_policy" {
  description = "(Required) The policy document. This is a JSON formatted string."
}