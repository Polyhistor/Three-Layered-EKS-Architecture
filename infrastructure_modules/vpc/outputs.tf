output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = module.vpc.vpc_instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = module.vpc.vpc_enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = module.vpc.vpc_enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = module.vpc.vpc_main_route_table_id
}

output "vpc_secondary_cidr_blocks" {
  description = "List of secondary CIDR blocks of the VPC"
  value       = module.vpc.vpc_secondary_cidr_blocks
}

output "private_subnets" {
  description = "List of private subnets"
  value       = module.vpc.private_subnets
}

output "private_subnets_cidr_blocks" {
  description = "List of cidr_blocks of private subnets"
  value       = module.vpc.private_subnets_cidr_blocks
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

output "public_subnets" {
  description = "List of public subnets"
  value       = module.vpc.public_subnets
}

output "public_subnets_cidr_blocks" {
  description = "List of cidr_blocks of public subnets"
  value       = module.vpc.public_subnets_cidr_blocks
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}

output "database_subnet_arns" {
  description = "List of ARNs of database subnets"
  value       = module.vpc.database_subnet_arns
}

output "database_subnets_cidr_blocks" {
  description = "List of cidr_blocks of database subnets"
  value       = module.vpc.database_subnets_cidr_blocks
}

output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.vpc.database_route_table_ids
}

output "database_subnet_group" {
  description = "ID of database subnet group"
  value       = module.vpc.database_subnet_group
}

output "nat_ids" {
  description = "List of allocation ID of Elastic IPs created { Gateway"
  value       = module.vpc.nat_ids
}

output "nat_public_ips" {
  description = "List of public Elastic IPs created { Gateway"
  value       = module.vpc.nat_public_ips
}

output "natgw_ids" {
  description = "List { IDs"
  value       = module.vpc.natgw_ids
}

output "igw_id" {
  description = "The ID of the Internet Gateway"
  value       = module.vpc.igw_id
}

output "public_network_acl_id" {
  description = "ID of the public network ACL"
  value       = module.vpc.public_network_acl_id
}

output "private_network_acl_id" {
  description = "ID of the private network ACL"
  value       = module.vpc.private_network_acl_id
}

output "database_network_acl_id" {
  description = "ID of the database network ACL"
  value       = module.vpc.database_network_acl_id
}

## Public Security Group ##
output "public_security_group_id" {
  value = module.public_security_group.this_security_group_id
}

output "public_security_group_vpc_id" {
  value = module.public_security_group.this_security_group_vpc_id
}

output "public_security_group_owner_id" {
  value = module.public_security_group.this_security_group_owner_id
}

output "public_security_group_name" {
  value = module.public_security_group.this_security_group_name
}

## Private Security Group ##
output "private_security_group_id" {
  value = module.private_security_group.this_security_group_id
}

output "private_security_group_vpc_id" {
  value = module.private_security_group.this_security_group_vpc_id
}

output "private_security_group_owner_id" {
  value = module.private_security_group.this_security_group_owner_id
}

output "private_security_group_name" {
  value = module.private_security_group.this_security_group_name
}

## Database Security Group ##
output "database_security_group_id" {
  value = module.database_security_group.this_security_group_id
}

output "database_security_group_vpc_id" {
  value = module.database_security_group.this_security_group_vpc_id
}

output "database_security_group_owner_id" {
  value = module.database_security_group.this_security_group_owner_id
}

output "database_security_group_name" {
  value = module.database_security_group.this_security_group_name
}