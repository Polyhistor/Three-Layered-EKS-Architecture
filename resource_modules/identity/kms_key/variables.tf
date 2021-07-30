########################################
# Variables
########################################

variable "description" {
  description = "The description of the key as viewed in AWS console."
  type = string
}

variable "name" {
  description = "The display name of the alias. The name must start with the word 'alias' followed by a forward slash (alias/)."
  type = string
}

variable "deletion_window_in_days" {
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  type = string
}

variable "policy" {
  type = string
  description = " A valid policy JSON document"
}

variable "enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
}

variable "tags" {
  description = "A mapping of tags to assign to the object."
  type = map
}
