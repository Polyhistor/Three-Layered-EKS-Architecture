########################################
# Variables
########################################

variable "name" {
  description = "The name of the table, this needs to be unique within a region."
  type = string
}

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
  description = "Encryption at rest."
  type = string
}

variable "tags" {
  description = "A map of tags to populate on the created table."
  type = map
}
