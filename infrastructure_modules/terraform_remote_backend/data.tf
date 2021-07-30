########################################
# Data sources
########################################

# Computed variables
locals {
  region_tag = {
    "us-east-1"    = "ue1"
    "us-west-1"    = "uw1"
    "eu-west-1"    = "ew1"
    "eu-central-1" = "ec1"
    "ap-northeast-1" = "apne1"
  }

  ########################################
  ## Terraform State S3 Bucket
  ########################################
  bucket_name = "s3-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-terraform-backend-${random_integer.digits.result}"
  acl         = "private"
  tags        = merge(
                  var.tags, 
                  tomap({
                      "Name" = local.bucket_name
                  })
                )

  website   = {}
  cors_rule = {}
  versioning = {
    enabled = var.versioning_enabled
    # can't seem to be done from TF
    # mfa_delete = true
  }
  logging                   = {}
  lifecycle_rule            = []
  replication_configuration = {}
  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = module.s3_kms_key_terraform_backend.arn # use custom KMS key created in a separate module
      }
    }
  }
  object_lock_configuration = {}

  ########################################
  ## Dynamodb for TF state locking
  ########################################
  dynamodb_name = "dynamo-${local.region_tag[var.region]}-${lower(var.app_name)}-${var.env}-terraform-state-lock"

  ########################################
  ## KMS
  ########################################
  ami_kms_key_name                    = "alias/cmk-${local.region_tag[var.region]}-${var.env}-s3-terraform-backend"
  ami_kms_key_description             = "Kms key used for Terraform remote states stored in S3"
  ami_kms_key_deletion_window_in_days = "30"
  ami_kms_key_tags = merge(
    var.tags,
    tomap({
        "Name" = local.ami_kms_key_name
    })
  )
}

# Current account ID
data "aws_caller_identity" "this" {}

# S3 Bucket Policy
data "aws_iam_policy_document" "bucket_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*",
    ]
  }
}

data "aws_iam_policy_document" "s3_terraform_states_kms_key_policy" {
  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        # "arn:aws:iam::${data.aws_caller_identity.this.account_id}:role/TerraformBuilder",
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    actions = [
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow use of the key"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = ["*"]
  }

  statement {
    sid    = "Allow attachment of persistent resources"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.this.account_id}:root",
      ]
    }

    actions = [
      "kms:CreateGrant",
      "kms:ListGrants",
      "kms:RevokeGrant",
    ]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}