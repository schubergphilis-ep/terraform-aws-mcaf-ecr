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
  description = "The tag mutability setting for repositories created by the template. Must be: `MUTABLE`, `IMMUTABLE`, `IMMUTABLE_WITH_EXCLUSION` or `MUTABLE_WITH_EXCLUSION`"

  validation {
    condition = (
      length(var.image_tag_mutability_exclusion_filter) == 0
      || contains(["IMMUTABLE_WITH_EXCLUSION", "MUTABLE_WITH_EXCLUSION"], var.image_tag_mutability)
    )
    error_message = "If image_tag_mutability_exclusion_filter is set, image_tag_mutability must be `IMMUTABLE_WITH_EXCLUSION` or `MUTABLE_WITH_EXCLUSION`."
  }
}

variable "image_tag_mutability_exclusion_filter" {
  type        = list(string)
  default     = []
  nullable    = false
  description = "List of image tag filters excluded from the `image_tag_mutability` setting for repositories created by the template. Wildcards (`*`) are supported, e.g. `latest` or `v*`"
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
