resource "aws_ecr_pull_through_cache_rule" "default" {
  for_each = { for k, v in var.pull_through_cache_rules : k => v if var.create }

  credential_arn        = try(each.value.credential_arn, null)
  ecr_repository_prefix = each.value.ecr_repository_prefix
  upstream_registry_url = each.value.upstream_registry_url
}

resource "aws_ecr_registry_policy" "default" {
  count = var.create && var.create_registry_policy ? 1 : 0

  policy = data.aws_iam_policy_document.registry.json
}

module "ecr_repo_creation_template_role" {
  count = var.create && var.create_ecr_repository_creation_role ? 1 : 0

  source  = "schubergphilis-ep/mcaf-role/aws"
  version = "~> 0.5.3"

  name                  = "EcrRepositoryCreationTemplate"
  create_policy         = true
  permissions_boundary  = var.permissions_boundary != null ? "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy${var.permissions_boundary}" : null
  postfix               = false
  principal_identifiers = ["ecr.amazonaws.com"]
  principal_type        = "Service"
  role_policy           = data.aws_iam_policy_document.ecr_repo_creation_template.json
}

resource "aws_ecr_repository_creation_template" "default" {
  for_each = { for k, v in var.pull_through_cache_rules : k => v if var.create }

  custom_role_arn      = try(module.ecr_repo_creation_template_role[0].arn, var.custom_ecr_repository_creation_role_arn)
  image_tag_mutability = "IMMUTABLE"
  prefix               = each.value.ecr_repository_prefix
  repository_policy    = data.aws_iam_policy_document.creation_template.json
  resource_tags        = var.resource_tags

  applied_for = [
    "PULL_THROUGH_CACHE",
  ]

  encryption_configuration {
    encryption_type = var.kms_key_arn != null ? "KMS" : "AES256"
    kms_key         = var.kms_key_arn
  }
}
