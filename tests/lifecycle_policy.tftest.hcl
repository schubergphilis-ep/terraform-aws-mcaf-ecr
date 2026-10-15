mock_provider "aws" {}

variables {
  repository_names = ["image-x", "team/image-y"]
}

run "default_expires_untagged_images" {
  command = plan

  assert {
    condition     = keys(aws_ecr_lifecycle_policy.default) == ["image-x", "team/image-y"]
    error_message = "Expected one lifecycle policy per repository, got ${jsonencode(keys(aws_ecr_lifecycle_policy.default))}."
  }

  assert {
    condition     = length(jsondecode(aws_ecr_lifecycle_policy.default["team/image-y"].policy).rules) == 1
    error_message = "Expected a single default rule, got ${aws_ecr_lifecycle_policy.default["team/image-y"].policy}."
  }

  assert {
    condition = jsondecode(aws_ecr_lifecycle_policy.default["team/image-y"].policy).rules[0].selection == {
      countNumber = 1
      countType   = "sinceImagePushed"
      countUnit   = "days"
      tagStatus   = "untagged"
    }
    error_message = "Expected the default rule to select untagged images older than 1 day, got ${aws_ecr_lifecycle_policy.default["team/image-y"].policy}."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.default["team/image-y"].policy).rules[0].action.type == "expire"
    error_message = "Expected the default rule to expire images, got ${aws_ecr_lifecycle_policy.default["team/image-y"].policy}."
  }

  assert {
    condition     = aws_ecr_lifecycle_policy.default["image-x"].policy == aws_ecr_lifecycle_policy.default["team/image-y"].policy
    error_message = "Expected every repository to get the same lifecycle policy."
  }
}

run "custom_rules" {
  command = plan

  variables {
    custom_lifecycle_policy_rules = <<-EOT
      {
        "rules": [
          {
            "rulePriority": 1,
            "description": "Keep the last 30 images",
            "selection": {
              "tagStatus": "any",
              "countType": "imageCountMoreThan",
              "countNumber": 30
            },
            "action": {
              "type": "expire"
            }
          }
        ]
      }
    EOT
  }

  assert {
    condition     = alltrue([for p in aws_ecr_lifecycle_policy.default : jsondecode(p.policy) == jsondecode(var.custom_lifecycle_policy_rules)])
    error_message = "Expected every lifecycle policy to be the custom policy, got ${jsonencode([for p in aws_ecr_lifecycle_policy.default : p.policy])}."
  }

  assert {
    condition     = !strcontains(aws_ecr_lifecycle_policy.default["image-x"].policy, "untagged")
    error_message = "Expected the custom policy to replace the default untagged rule, got ${aws_ecr_lifecycle_policy.default["image-x"].policy}."
  }
}

run "empty_custom_rules_use_default" {
  command = plan

  variables {
    custom_lifecycle_policy_rules = ""
  }

  assert {
    condition     = length(jsondecode(aws_ecr_lifecycle_policy.default["image-x"].policy).rules) == 1
    error_message = "Expected the single default rule, got ${aws_ecr_lifecycle_policy.default["image-x"].policy}."
  }

  assert {
    condition     = jsondecode(aws_ecr_lifecycle_policy.default["image-x"].policy).rules[0].selection.tagStatus == "untagged"
    error_message = "Expected an empty custom policy to fall back to the default untagged rule, got ${aws_ecr_lifecycle_policy.default["image-x"].policy}."
  }
}

run "lifecycle_policy_disabled" {
  command = plan

  variables {
    enable_lifecycle_policy = false
  }

  assert {
    condition     = length(aws_ecr_lifecycle_policy.default) == 0
    error_message = "Expected no lifecycle policy, got ${jsonencode(keys(aws_ecr_lifecycle_policy.default))}."
  }

  assert {
    condition     = keys(aws_ecr_repository.default) == ["image-x", "team/image-y"]
    error_message = "Expected the repositories to be planned without lifecycle policies, got ${jsonencode(keys(aws_ecr_repository.default))}."
  }
}
