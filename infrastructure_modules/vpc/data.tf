locals {
  ## VPC ##  
  public_subnet_tags = {
    # need to tag subnets with "shared" so K8s can find right subnets to create ELBs
    # ref: https://github.com/kubernetes/kubernetes/issues/29298, https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/basic/main.tf
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/role/elb"                    = 1 # need this tag for public ELB. Ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "Tier"                                      = "public"
  }

  # need tag for internal-elb to be able to create ELB
  private_subnet_tags = {
    # "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    # "kubernetes.io/role/internal-elb"           = 1 # need this tag for internal ELB. Ref: https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "Tier"                                      = "private"
  }

  database_subnet_tags = {
    "Tier" = "database"
  }

  ## Public SG ##
  public_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-public"
  public_security_group_description = "Security group for public subnets"
  public_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.public_security_group_name
    }),
    tomap({
        "Tier" = "public"
    })
  )

  ## Private SG ##
  private_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-private"
  private_security_group_description = "Security group for private subnets"
  private_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.private_security_group_name
    }),
    tomap({
        "Tier" = "private"
    })
  )

  ## DB SG ##
  db_security_group_name        = "scg-${var.region_tag[var.region]}-${var.env}-database"
  db_security_group_description = "Security group for database subnets"
  db_security_group_tags = merge(
    var.tags,
    tomap({
        "Name" = local.db_security_group_name
    }),
    tomap({
        "Tier" = "database"
    })
  )

  db_security_group_computed_ingress_with_source_security_group_id = [
    {
      rule                     = "mongodb-27017-tcp"
      source_security_group_id = module.private_security_group.this_security_group_id
      description              = "mongodb-27017 from private SG"
    },
    {
      rule                     = "mongodb-27018-tcp"
      source_security_group_id = module.private_security_group.this_security_group_id
      description              = "mongodb-27018 from private SG"
    },
    {
      rule                     = "mongodb-27019-tcp"
      source_security_group_id = module.private_security_group.this_security_group_id
      description              = "mongodb-27019 from private SG"
    },
    {
      rule                     = "mysql-tcp"
      source_security_group_id = module.private_security_group.this_security_group_id
      description              = "mysql-3306 from private SG"
    },
    # DB Controller EC2 not created yet
    # {
    #   rule                     = "mongodb-27017-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27017 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mongodb-27018-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27018 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mongodb-27019-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mongodb-27019 from DB controller in private subnet"
    # },
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = var.databse_computed_ingress_with_db_controller_source_security_group_id
    #   description              = "mysql-3306 from DB Controller SG"
    # },
    # EKS SG not created yet
    # {
    #   rule                     = "mysql-tcp"
    #   source_security_group_id = data.aws_security_group.eks_worker_sg.id
    #   description              = "mysql-3306 from private SG in peerwell-devops account"
    # },
  ]
}

# EKS worker SG not created yet
# data "aws_security_group" "eks_worker_sg" {
#   tags = {
#     Name = "eks-ue1-prod-peerwell-api-infra-eks_worker_sg"
#   }

#   id = "sg-08fc14b9cb38d325c"
# }