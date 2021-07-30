# Create EKS Cluster

![alt text](../imgs/eks.png "")


Project architecture:
```sh
.
├── README.md
├── composition
│   ├── eks-demo-infra # <--- Step 3: Create Composition layer and define all the required inputs to Infrastructure module's EKS main.tf
│   │   └── ap-northeast-1
│   │       └── prod
│   │           ├── backend.config
│   │           ├── data.tf
│   │           ├── main.tf # <----- this is the entry point for EKS
│   │           ├── outputs.tf
│   │           ├── providers.tf
│   │           ├── terraform.tfenvs
│   │           └── variables.tf
│   └── terraform-remote-backend 
│       └── ap-northeast-1 
│           └── prod      
│               ├── data.tf
│               ├── main.tf 
│               ├── outputs.tf
│               ├── providers.tf
│               ├── terraform.tfstate
│               ├── terraform.tfstate.backup
│               ├── terraform.tfvars
│               └── variables.tf
├── infrastructure_modules 
│   ├── eks # <---- Step 2: Create Infrastructure Modules for VPC and Consume Resource Modules
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── template
│   │   │   └── ssm_document_cleanup_docker_images.yaml
│   │   └── variables.tf
│   ├── terraform_remote_backend
│   │   ├── data.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variables.tf
│   └── vpc
│       ├── data.tf
│       ├── main.tf
│       ├── outputs.tf
│       ├── provider.tf
│       ├── variables.tf
│       └── versions.tf
└── resource_modules 
    ├── compute
    │   ├── ec2_key_pair
    │   │   ├── main.tf
    │   │   ├── output.tf
    │   │   └── variables.tf
    │   └── security_group
    │       ├── main.tf
    │       ├── outputs.tf
    │       ├── rules.tf
    │       ├── update_groups.sh
    │       └── variables.tf
    ├── container
    │   ├── ecr
    │   │   ├── main.tf
    │   │   ├── outputs.tf
    │   │   └── variables.tf
    │   └── eks # <----- Step 1: Replicate remote TF modules in local Resource Modules
    │       ├── aws_auth.tf
    │       ├── cluster.tf
    │       ├── data.tf
    │       ├── irsa.tf
    │       ├── kubectl.tf
    │       ├── local.tf
    │       ├── modules
    │       │   ├── fargate
    │       │   │   ├── data.tf
    │       │   │   ├── fargate.tf
    │       │   │   ├── outputs.tf
    │       │   │   └── variables.tf
    │       │   └── node_groups
    │       │       ├── README.md
    │       │       ├── locals.tf
    │       │       ├── node_groups.tf
    │       │       ├── outputs.tf
    │       │       ├── ramdom.tf
    │       │       └── variables.tf
    │       ├── node_groups.tf
    │       ├── outputs.tf
    │       ├── scripts
    │       ├── templates
    │       │   ├── kubeconfig.tpl
    │       │   └── userdata.sh.tpl
    │       ├── variables.tf
    │       ├── versions.tf
    │       ├── workers.tf
    │       └── workers_launch_template.tf
    ├── database
    │   └── dynamodb
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    ├── identity
    │   └── kms_key
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf 
    ├── network
    │   └── vpc 
    │       ├── main.tf
    │       ├── outputs.tf
    │       └── variables.tf
    └── storage
        └── s3   
            ├── main.tf      
            ├── outputs.tf
            └── variables.tf
```

# Step 1: Replicate Remote TF modules for EKS in local Resource Modules

## EKS
Copy paste all the .tf and `/templates` and `/scripts` at the root of this repo https://github.com/terraform-aws-modules/terraform-aws-eks to `resource_modules/network/vpc`.


In [resource_modules/container/eks/workers.tf](resource_modules/container/eks/workers.tf), use `substr()`
```
resource "aws_iam_role" "workers" {
  name_prefix           = substr(var.workers_role_name != "" ? null : coalescelist(aws_eks_cluster.this[*].name, [""])[0], 0, 31)
```


In [resource_modules/container/eks/variables.tf](resource_modules/container/eks/variables.tf),
```sh
# externalize this var so value can be injected at higher level (infra modules)
variable "key_name" {
  default = ""
}
```

In [resource_modules/container/eks/local.tf](resource_modules/container/eks/local.tf),
```sh
workers_group_defaults_defaults = {
    root_volume_type              = "gp2"
    key_name                      = var.key_name       # The key pair name that should be used for the instances in the autoscaling group
```





# Step 2: Create Infrastructure Modules for EKS and Consume Resource Modules

Using [AWS EKS Terraform Remote Module's examples](https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/basic/main.tf), create EKS infra module's main.tf.

In [infrastructure_modules/eks/main.tf](infrastructure_modules/eks/main.tf), module `eks` will act as a __facade__ to many sub-components such as EKS cluster, EKS worker nodes, IAM roles, worker launch template, security groups, auto scaling groups, etc.

```sh
module "key_pair" {
  source = "../../resource_modules/compute/ec2_key_pair"

  key_name   = local.key_pair_name
  public_key = local.public_key
}

# ref: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/basic/main.tf#L125-L160
module "eks_cluster" {
  source = "../../resource_modules/container/eks"

  create_eks      = var.create_eks
  cluster_version = var.cluster_version
  cluster_name    = var.cluster_name
  kubeconfig_name = var.cluster_name
  vpc_id          = var.vpc_id
  subnets         = var.subnets

  worker_groups                        = var.worker_groups
  node_groups                          = var.node_groups
  worker_additional_security_group_ids = var.worker_additional_security_group_ids

  map_roles                                  = var.map_roles
  map_users                                  = var.map_users
  kubeconfig_aws_authenticator_env_variables = var.kubeconfig_aws_authenticator_env_variables

  key_name = module.key_pair.key_name

  # WARNING: changing this will force recreating an entire EKS cluster!!!
  # enable k8s secret encryption using AWS KMS. Ref: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/examples/secrets_encryption/main.tf#L88
  cluster_encryption_config = [
    {
      provider_key_arn = module.k8s_secret_kms_key.arn
      resources        = ["secrets"]
    }
  ]

  tags = var.tags
}

# ########################################
# ## KMS for K8s secret's DEK (data encryption key) encryption
# ########################################
module "k8s_secret_kms_key" {
  source = "../../resource_modules/identity/kms_key"

  name                    = local.k8s_secret_kms_key_name
  description             = local.k8s_secret_kms_key_description
  deletion_window_in_days = local.k8s_secret_kms_key_deletion_window_in_days
  tags                    = local.k8s_secret_kms_key_tags
  policy                  = data.aws_iam_policy_document.k8s_api_server_decryption.json
  enable_key_rotation     = true
}
```


Create public and private key locally using `ssh-keygen`, then copy public key content in [infrastructure_modules/eks/data.tf](infrastructure_modules/eks/data.tf):

```sh
locals {
  ## Key Pair ##
  key_pair_name = "eks-workers-keypair-${var.region_tag[var.region]}-${var.env}-${var.app_name}"
  # run "ssh-keygen" then copy public key content to public_key
  public_key    = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC+6hyhXItMXzNI/P481x2BsIU2VEVE4N2ET43GMxr1y+Hufa58BIzd0I7JuForq8kufhx2PhWnlD6wj6YKYti5qu4nvaKbVABYtzO0QN6SLo48kvmdwX4UF+QLO/YoBau/czq1zgxZ18F3kQ/Z0rdy11O7tU7dRDUGvpCNL8G+Qkadwt39AIXd3923GMtB8TxjWN4HeKLD9VGDOyD9WgmIwuC8/hJhej9AaqA/zKDcgune8ZPv8AQ7STzKNynnKaGjzpZPeY9xvPBsNEZjCJsKt3XBQGd+Hz3DtmGrsCMAbF5FUdZll5fzgZK46zwXnRRp2XjUEfUJyoLhaaay1Yvd usermane@User-MBP.w.mifi"

```


# Step 3: Create Composition layer and define all the required inputs to Infrastructure VPC module's main.tf

In [composition/eks-demo-infra/ap-northeast-1/prod/main.tf](composition/eks-demo-infra/ap-northeast-1/prod/main.tf), a single module called `vpc` is defined.


```sh
########################################
# EKS
########################################
module "eks" {
  source = "../../../../infrastructure_modules/eks"

  ## EKS ##
  create_eks      = var.create_eks
  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name
  vpc_id          = local.vpc_id
  subnets         = local.private_subnets

  # note: either pass worker_groups or node_groups
  # this is for (EKSCTL API) unmanaged node group
  worker_groups = var.worker_groups

  # this is for (EKS API) managed node group
  node_groups = var.node_groups

  # worker_additional_security_group_ids = [data.aws_security_group.client_vpn_sg.id]

  # add roles that can access K8s cluster
  #map_roles = local.map_roles
  # add IAM users who can access K8s cluster
  #map_users = var.map_users

  # specify AWS Profile if you want kubectl to use a named profile to authenticate instead of access key and secret access key
  kubeconfig_aws_authenticator_env_variables = local.kubeconfig_aws_authenticator_env_variables

  ## Common tag metadata ##
  env             = var.env
  app_name        = var.app_name
  tags            = local.eks_tags
  region          = var.region
}
```

Also, you need to define `kubernetes` provider
```sh
terraform {
  required_version = ">= 0.14"
  backend "s3" {} # use backend.config for remote backend

  required_providers {
    aws    = ">= 3.28, < 4.0"
    random = "~> 2"
    kubernetes = "~>1.11"
    local = "~> 1.2"
    null = "~> 2.1"
    template = "~> 2.1"
  }
}

# In case of not creating the cluster, this will be an incompletely configured, unused provider, which poses no problem.
# ref: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
provider "kubernetes" {
  # if you use default value of "manage_aws_auth = true" then you need to configure the kubernetes provider as per the doc: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v12.1.0/README.md#conditional-creation, https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911
  host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, list("")), 0)
  cluster_ca_certificate = base64decode(element(concat(data.aws_eks_cluster.cluster[*].certificate_authority.0.data, list("")), 0))
  token                  = element(concat(data.aws_eks_cluster_auth.cluster[*].token, list("")), 0)
  load_config_file       = false # set to false unless you want to import local kubeconfig to terraform
}
```

And data
```sh
# if you leave default value of "manage_aws_auth = true" then you need to configure the kubernetes provider as per the doc: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/v12.1.0/README.md#conditional-creation, https://github.com/terraform-aws-modules/terraform-aws-eks/issues/911
data "aws_eks_cluster" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  count = var.create_eks ? 1 : 0
  name  = module.eks.cluster_id
}
```



Finally supply input variable values in [composition/eks-demo-infra/ap-northeast-1/prod/terraform.tfvars](composition/eks-demo-infra/ap-northeast-1/prod/terraform.tfvars):

```sh
########################################
# EKS
########################################
cluster_version = 1.19

# if set to true, AWS IAM Authenticator will use IAM role specified in "role_name" to authenticate to a cluster
authenticate_using_role = true

# if set to true, AWS IAM Authenticator will use AWS Profile name specified in profile_name to authenticate to a cluster instead of access key and secret access key
authenticate_using_aws_profile = false

# WARNING: mixing managed and unmanaged node groups will render unmanaged nodes to be unable to connect to internet & join the cluster when restarting.
# how many groups of K8s worker nodes you want? Specify at least one group of worker node
# gotcha: managed node group doesn't support 1) propagating taint to K8s nodes and 2) custom userdata. Ref: https://eksctl.io/usage/eks-managed-nodes/#feature-parity-with-unmanaged-nodegroups
node_groups = {}

# note (only for unmanaged node group)
worker_groups = [
  {
    name                 = "worker-group-prod-1"
    instance_type        = "m3.medium" # since we are using AWS-VPC-CNI, allocatable pod IPs are defined by instance size: https://docs.google.com/spreadsheets/d/1MCdsmN7fWbebscGizcK6dAaPGS-8T_dYxWp0IdwkMKI/edit#gid=1549051942, https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
    asg_max_size         = 2
    asg_min_size         = 1
    asg_desired_capacity = 1 # this will be ignored if cluster autoscaler is enabled: asg_desired_capacity: https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/docs/autoscaling.md#notes
    tags = [
      {
        "key"                 = "unmanaged-node"
        "propagate_at_launch" = "true"
        "value"               = "true"
      },
    ]
  },
]
```

Then run terraform commands
```sh
cd composition/eks-demo-infra/ap-northeast-1/prod

# will use remote backend
terraform init -backend-config=backend.config

# usual steps
terraform plan
terraform apply

# wait for about 15 minutes!!
module.eks.module.eks_cluster.null_resource.wait_for_cluster[0]: Still creating... [14m51s elapsed]
module.eks.module.eks_cluster.null_resource.wait_for_cluster[0]: Still creating... [15m1s elapsed]
module.eks.module.eks_cluster.null_resource.wait_for_cluster[0]: Creation complete after 15m6s [id=2913039165535485096]
data.aws_eks_cluster_auth.cluster[0]: Reading...
data.aws_eks_cluster.cluster[0]: Reading...
data.aws_eks_cluster_auth.cluster[0]: Read complete after 0s [id=eks-apne1-prod-terraform-eks-demo-infra]
data.aws_eks_cluster.cluster[0]: Read complete after 1s [id=eks-apne1-prod-terraform-eks-demo-infra]
module.eks.module.eks_cluster.kubernetes_config_map.aws_auth[0]: Creating...
module.eks.module.eks_cluster.kubernetes_config_map.aws_auth[0]: Creation complete after 2s [id=kube-system/aws-auth]

# Successful output
Apply complete! Resources: 36 added, 0 changed, 0 destroyed.
```


## Step 4: Configure local kubeconfig to access EKS cluster
Ref: https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/


By default, kubectl will look for kubeconfig stored in `~/.kube/config`, if not then the path found in env variable `KUBECONFIG`.


### Scenario 1: the default kubeconfig is empty
If you don't have any other k8s cluster config stored in `~/.kube/config`, then you can overwrite it with the EKS cluster config.

First output kubeconfig contents using `terraform output`:
```sh
# show contents of kubeconfig for this EKS cluster
terraform output eks_kubeconfig

# show file name of kubeconfig stored locally
terraform output eks_kubeconfig_filename

# optionally, you can write contents to the default kubeconfig path
terraform output eks_kubeconfig > `~/.kube/config`

# check authentication
kubectl cluster-info

# output
Kubernetes master is running at https://EFFDE7B864F8D3778BD3417E5572FAE0.gr7.ap-northeast-1.eks.amazonaws.com
CoreDNS is running at https://EFFDE7B864F8D3778BD3417E5572FAE0.gr7.ap-northeast-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.
```

### Scenario 2: the default kubeconfig is NOT empty and you will manually edit it
If you already have another k8s cluster config in `~/.kube/config` and you don't want to overwrite the file, you can manually edit the file by adding the EKS cluster info.

### Scenario 3: the default kubeconfig is NOT empty and you want to keep a separate kubeconfig file
Or you can pass `-kubeconfig` argument to `kubectl` command to refer to other kubeconfig file without editing `~/.kube/config` at all
```sh
# write contents to the default kubeconfig path
terraform output eks_kubeconfig > `~/.kube/eks-apne1-prod-terraform-eks-demo-infra`

# check authentication by specifying a non-default kubeconfig file path
kubectl cluster-info \
  --kubeconfig=./kubeconfig_eks-apne1-prod-terraform-eks-demo-infra

# output
Kubernetes master is running at https://EFFDE7B864F8D3778BD3417E5572FAE0.gr7.ap-northeast-1.eks.amazonaws.com
CoreDNS is running at https://EFFDE7B864F8D3778BD3417E5572FAE0.gr7.ap-northeast-1.eks.amazonaws.com/api/v1/namespaces/kube-system/services/kube-dns:dns/proxy

To further debug and diagnose cluster problems, use 'kubectl cluster-info dump'.

# you need to specify --kubeconfig for each kubectl command
kubectl get po --kubeconfig=./kubeconfig_eks-apne1-prod-terraform-eks-demo-infra

# if you don't want to pass --kubeconfig everytime, you can set ENV KUBECONFIG in current shell
export KUBECONFIG="${PWD}/kubeconfig_eks-apne1-prod-terraform-eks-demo-infra"
kubectl get po
```


Destroy only `eks` module
```
terraform state list

terraform destroy -target=module.eks
```