module "vpc" {
  source = "../../resource_modules/network/vpc"

  name = var.name
  cidr = var.cidr

  azs              = var.azs
  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  enable_nat_gateway = var.enable_nat_gateway
  single_nat_gateway = var.single_nat_gateway

  tags                 = var.tags
  public_subnet_tags   = local.public_subnet_tags
  private_subnet_tags  = local.private_subnet_tags
  database_subnet_tags = local.database_subnet_tags

  # VPC Flow Logs (Cloudwatch log group and IAM role will be created)
  enable_flow_log                      = true
  create_flow_log_cloudwatch_log_group = true
  create_flow_log_cloudwatch_iam_role  = true
  flow_log_max_aggregation_interval    = 60
}

# allow ingress for port 80 & 443 from anywhere (i.e. source CIDR 0.0.0.0/0)
module "public_security_group" {
  source = "../../resource_modules/compute/security_group"

  name        = local.public_security_group_name
  description = local.public_security_group_description
  vpc_id      = module.vpc.vpc_id

  ingress_rules            = ["http-80-tcp", "https-443-tcp"] # ref: https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/complete/main.tf#L44
  ingress_cidr_blocks      = ["0.0.0.0/0"]
  ingress_with_cidr_blocks = var.public_ingress_with_cidr_blocks

  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.public_security_group_tags
}

# allow ingress only from public SG for port 80, 443, and 22
module "private_security_group" {
  source = "../../resource_modules/compute/security_group"

  name        = local.private_security_group_name
  description = local.private_security_group_description
  vpc_id      = module.vpc.vpc_id

  # define ingress source as computed security group IDs, not CIDR block
  # ref: https://github.com/terraform-aws-modules/terraform-aws-security-group/blob/master/examples/complete/main.tf#L150
  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "http-80-tcp"
      source_security_group_id = module.public_security_group.this_security_group_id
      description              = "Port 80 from public SG rule"
    },
    {
      rule                     = "https-443-tcp"
      source_security_group_id = module.public_security_group.this_security_group_id
      description              = "Port 443 from public SG rule"
    },
    # bastion EC2 not created yet 
    # {
    #   rule                     = "ssh-tcp"
    #   source_security_group_id = var.bastion_sg_id
    #   description              = "SSH from bastion SG rule"
    # },
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  # allow ingress from within (i.e. connecting from EC2 to other EC2 associated with the same private SG)
  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    },
  ]

  # allow all egress
  egress_rules                                             = ["all-all"]
  tags                                                     = local.private_security_group_tags
}

# allow ingress from private SG for port 27017-19 for mongoDB and port 3306 for MySQL
module "database_security_group" {
  source = "../../resource_modules/compute/security_group"

  name        = local.db_security_group_name
  description = local.db_security_group_description
  vpc_id      = module.vpc.vpc_id

  # combine list of SG rules from EKS worker SG and private SG
  computed_ingress_with_source_security_group_id           = concat(local.db_security_group_computed_ingress_with_source_security_group_id, var.databse_computed_ingress_with_eks_worker_source_security_group_ids)
  number_of_computed_ingress_with_source_security_group_id = var.create_eks ? 7 : 4

  # Open for self (rule or from_port+to_port+protocol+description)
  ingress_with_self = [
    {
      rule        = "all-all"
      description = "Self"
    },
  ]

  # allow all egress
  egress_rules = ["all-all"]
  tags         = local.db_security_group_tags
}