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

variable "repository_creation_role_name" {
  type        = string
  default     = "EcrRepositoryCreationTemplate"
  description = "Name of the IAM role used by the repository creation template. Must be unique within the AWS account"
}

variable "resource_tags" {
  type        = map(string)
  default     = {}
  description = "The resource tags"
}
