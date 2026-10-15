variable "additional_ecr_policy_statements" {
  type = map(object({
    effect = string
    principal = object({
      type        = string
      identifiers = list(string)
    })
    actions = list(string)
    condition = optional(list(object({
      test     = string
      variable = string
      values   = list(string)
    })), [])
  }))
  description = "Map of additional ecr repository policy statements"
  default     = null
}

variable "custom_lifecycle_policy_rules" {
  type        = string
  description = "JSON definition of custom policy Rules, this will disable the default policy"
  default     = null
}

variable "enable_lifecycle_policy" {
  type        = bool
  description = "Set to false to prevent the module from adding any lifecycle policies to any repositories"
  default     = true
}

variable "force_delete" {
  type        = bool
  default     = false
  description = "When deleting a repository, force the deletion if it is not empty"
}

variable "image_tag_mutability" {
  type        = string
  default     = "IMMUTABLE"
  description = "The tag mutability setting for the repository. Must be: `MUTABLE`, `IMMUTABLE`, `IMMUTABLE_WITH_EXCLUSION` or `MUTABLE_WITH_EXCLUSION`"

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
  description = "List of image tag filters excluded from the `image_tag_mutability` setting. Wildcards (`*`) are supported, e.g. `latest` or `v*`"
}

variable "kms_key_arn" {
  type        = string
  default     = null
  description = "The KMS key ARN used for the repository encryption"
}

variable "principals_readonly_access" {
  type        = list(string)
  default     = []
  description = "Principal ARNs to provide with readonly access to the ECR"
}

variable "repository_names" {
  type        = list(string)
  description = "list of repository names, names can include namespaces: prefixes ending with a slash (/)"

  validation {
    condition     = length(var.repository_names) > 0
    error_message = "At least one repository name must be provided"
  }
}

variable "repository_tags" {
  type        = map(map(string))
  default     = {}
  description = "Mapping of tags for a repository using repository name as key"
}

variable "scan_images_on_push" {
  type        = bool
  default     = true
  description = "Indicates if images are automatically scanned after being pushed to the repository"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Mapping of tags"
}
