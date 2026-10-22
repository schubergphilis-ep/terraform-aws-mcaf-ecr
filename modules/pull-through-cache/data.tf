data "aws_caller_identity" "current" {}

data "aws_region" "current" {
  region = var.region
}

# ECR Pull through cache - cross account
data "aws_iam_policy_document" "registry" {
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:BatchImportUpstreamImage"
    ]
    principals {
      type        = "AWS"
      identifiers = [for k in var.readonly_principals : "arn:aws:iam::${k}:root"]
    }
    resources = [
      "arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"
    ]
  }
}

data "aws_iam_policy_document" "creation_template" {
  statement {
    sid = "AllowPull"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:DescribeImages",
      "ecr:DescribeRepositories",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchImportUpstreamImage"
    ]
    principals {
      type        = "AWS"
      identifiers = [for k in var.readonly_principals : "arn:aws:iam::${k}:root"]
    }
  }
}

data "aws_iam_policy_document" "ecr_repo_creation_template" {
  statement {
    actions = [
      "kms:CreateGrant",
      "kms:RetireGrant",
      "kms:DescribeKey",
    ]

    resources = ["arn:aws:kms:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:key/*"]
  }
  statement {
    actions = [
      "ecr:CreateRepository",
      "ecr:ReplicateImage",
      "ecr:TagResource",
      "ecr:BatchImportUpstreamImage",
    ]

    resources = ["arn:aws:ecr:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:repository/*"]
  }
}
