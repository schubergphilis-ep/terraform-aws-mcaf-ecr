mock_provider "aws" {
  # Policy arguments are validated as JSON, even with a mocked provider.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

variables {
  pull_through_cache_rules = {
    ecrpub = {
      description           = "Amazon ECR Public"
      ecr_repository_prefix = "ecr-public"
      upstream_registry_url = "public.ecr.aws"
    }
  }
}

run "default_role_name" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  assert {
    condition     = module.ecr_repo_creation_template_role[0].name == "EcrRepositoryCreationTemplate"
    error_message = "Expected the role name to default to EcrRepositoryCreationTemplate."
  }
}

run "custom_role_name" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  variables {
    repository_creation_role_name = "EcrRepositoryCreationTemplateEcrPublic"
  }

  assert {
    condition     = module.ecr_repo_creation_template_role[0].name == "EcrRepositoryCreationTemplateEcrPublic"
    error_message = "Expected the role name to be EcrRepositoryCreationTemplateEcrPublic."
  }
}
