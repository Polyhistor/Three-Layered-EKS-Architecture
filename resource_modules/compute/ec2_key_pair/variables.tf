variable "key_name" {
  description = "(Optional) The name for the key pair."
  type = string
}

variable "public_key" {
  description = "(Optional) The public key material. "
  type = string
  default     = ""
}
