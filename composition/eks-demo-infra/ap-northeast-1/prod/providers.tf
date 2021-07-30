########################################
# Provider to connect to AWS
# https://www.terraform.io/docs/providers/aws/
########################################

terraform {
  required_version = ">= 0.14"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws        = ">= 3.28, < 4.0"
    random     = "~> 2"
    kubernetes = "~>1.11"
    local      = "~> 1.2"
    null       = "~> 2.1"
    template   = "~> 2.1"
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile_name
}

# In case of not creating the cluster, this will be an incompletely configured, unused provider, which poses no problem.
# ref: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
provider "kubernetes" {
  # if you use default value of "manage_aws_auth = true" then you need to configure the kubernetes provider as per the doc: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v12.1.0/README.md#conditional-creation, https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, tolist([""])), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, tolist([""])), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, tolist([""])), 0)
  load_config_file       = false # set to false unless you want to import local kubeconfig to terraform
}
