locals {
  ecr_policies = merge(local.readonly_ecr_policy, var.additional_ecr_policy_statements)

  policy_rule_untagged_image = [{
    action       = { type = "expire" }
    description  = "Keep untagged images for 1 day"
    rulePriority = 1

    selection = {
      countNumber = 1
      countType   = "sinceImagePushed"
      countUnit   = "days"
      tagStatus   = "untagged"
    }
  }]

  readonly_ecr_policy = length(var.principals_readonly_access) > 0 ? {
    "ReadonlyAccess" = {
      effect = "Allow"

      actions = [
        "ecr:BatchCheckLayerAvailability",
        "ecr:BatchGetImage",
        "ecr:DescribeImages",
        "ecr:DescribeImageScanFindings",
        "ecr:DescribeRepositories",
        "ecr:GetDownloadUrlForLayer",
        "ecr:GetLifecyclePolicy",
        "ecr:GetLifecyclePolicyPreview",
        "ecr:GetRepositoryPolicy",
        "ecr:ListImages",
        "ecr:ListTagsForResource",
      ]

      principal = {
        type        = "AWS"
        identifiers = [for k in var.principals_readonly_access : "arn:aws:iam::${k}:root"]
      }
    }
  } : null
}

resource "aws_ecr_repository" "default" {
  for_each = toset(var.repository_names)

  name                 = each.value
  force_delete         = var.force_delete
  image_tag_mutability = var.image_tag_mutability
  tags                 = merge(var.tags, try(var.repository_tags[each.value], {}))

  encryption_configuration {
    kms_key         = var.kms_key_arn
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
  }

  image_scanning_configuration {
    scan_on_push = var.scan_images_on_push
  }

  dynamic "image_tag_mutability_exclusion_filter" {
    for_each = var.image_tag_mutability_exclusion_filter != null && length(var.image_tag_mutability_exclusion_filter) > 0 ? var.image_tag_mutability_exclusion_filter : []
    content {
      filter      = image_tag_mutability_exclusion_filter.value.filter
      filter_type = image_tag_mutability_exclusion_filter.value.filter_type
    }
  }
}

locals {
  ecr_policy_to_apply = var.custom_lifecycle_policy_rules != null && var.custom_lifecycle_policy_rules != "" ? var.custom_lifecycle_policy_rules : jsonencode({
    rules = local.policy_rule_untagged_image
  })
}

resource "aws_ecr_lifecycle_policy" "default" {
  for_each = toset(var.enable_lifecycle_policy ? var.repository_names : [])

  repository = aws_ecr_repository.default[each.value].id

  policy = local.ecr_policy_to_apply
}


data "aws_iam_policy_document" "default" {
  count = length(local.ecr_policies) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = local.ecr_policies

    content {
      sid     = statement.key
      actions = statement.value.actions
      effect  = title(statement.value.effect)

      principals {
        type        = title(statement.value.principal.type)
        identifiers = statement.value.principal.identifiers
      }

      dynamic "condition" {
        for_each = try(statement.value.condition, [])

        content {
          test     = condition.value.test
          variable = condition.value.variable
          values   = condition.value.values
        }
      }
    }
  }
}

resource "aws_ecr_repository_policy" "default" {
  for_each = toset(length(local.ecr_policies) > 0 ? var.repository_names : [])

  repository = aws_ecr_repository.default[each.value].id
  policy     = join("", data.aws_iam_policy_document.default[*].json)
}
