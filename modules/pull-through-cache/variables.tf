variable "create" {
  type        = bool
  default     = true
  description = "Determines whether resources will be created (affects all resources)"
}

variable "create_ecr_repository_creation_role" {
  type        = bool
  default     = true
  description = "Create the IAM role used as a template for ECR repository creation."
}

variable "create_registry_policy" {
  type        = bool
  default     = false
  description = "Determines whether a registry policy will be created"
}

variable "custom_ecr_repository_creation_role_arn" {
  type        = string
  default     = null
  description = "Custom role ARN for the creation template"
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE" # AWS recommends MUTABLE for pull through cache: https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-creation-templates.html
  description = "The tag mutability setting for repositories created by the template. Must be: `MUTABLE`, `IMMUTABLE` or `IMMUTABLE_WITH_EXCLUSION`"

  validation {
    condition = (
      var.image_tag_mutability_exclusion_filter == null
      || length(var.image_tag_mutability_exclusion_filter) == 0
      || upper(var.image_tag_mutability) == "IMMUTABLE_WITH_EXCLUSION"
    )
    error_message = "If image_tag_mutability_exclusion_filter is set (non-null and non-empty), image_tag_mutability must be `IMMUTABLE_WITH_EXCLUSION`."
  }
}

variable "image_tag_mutability_exclusion_filter" {
  type = list(object({
    filter      = string
    filter_type = string
  }))
  default     = null
  description = "List of image tag exclusion filters for repositories created by the template"

  validation {
    condition = (
      var.image_tag_mutability_exclusion_filter == null
      || alltrue([
        for f in var.image_tag_mutability_exclusion_filter : upper(f.filter_type) == "WILDCARD"
      ])
    )
    error_message = "Every image_tag_mutability_exclusion_filter.filter_type must be 'WILDCARD' (case-insensitive)."
  }
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "The KMS key used for encryption"
}

variable "permissions_boundary" {
  type        = string
  default     = null
  description = "Name of Permissions Boundary, including path. (e.g. /ep/workload_boundary)"
}

variable "pull_through_cache_rules" {
  type = map(object({
    credential_arn        = optional(string)
    description           = string
    ecr_repository_prefix = string
    upstream_registry_url = string
  }))
  description = "List of pull through cache rules to create"
}

variable "readonly_principals" {
  type        = list(string)
  default     = []
  description = "List of AWS account IDs. Account IDs (12 digits) will be converted to `arn:aws:iam::<account-id>:root`."
}

variable "resource_tags" {
  type        = map(string)
  default     = {}
  description = "The resource tags"
}
