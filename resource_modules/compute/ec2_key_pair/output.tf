## AWS Key Pair ##
output "key_name" {
  description = "The key pair name."
  value       = aws_key_pair.this.key_name
}

output "fingerprint" {
  description = "The MD5 public key fingerprint as specified in section 4 of RFC 4716."
  value       = aws_key_pair.this.fingerprint
}