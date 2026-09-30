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

run "default_immutable" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  assert {
    condition     = aws_ecr_repository_creation_template.default["ecrpub"].image_tag_mutability == "IMMUTABLE"
    error_message = "Expected image_tag_mutability to default to IMMUTABLE."
  }

  assert {
    condition     = length(aws_ecr_repository_creation_template.default["ecrpub"].image_tag_mutability_exclusion_filter) == 0
    error_message = "Expected no image_tag_mutability_exclusion_filter by default."
  }
}

run "mutable" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  variables {
    image_tag_mutability = "MUTABLE"
  }

  assert {
    condition     = aws_ecr_repository_creation_template.default["ecrpub"].image_tag_mutability == "MUTABLE"
    error_message = "Expected image_tag_mutability to be MUTABLE."
  }
}

run "immutable_with_mutable_latest" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  variables {
    image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

    image_tag_mutability_exclusion_filter = [
      {
        filter      = "latest"
        filter_type = "WILDCARD"
      },
    ]
  }

  assert {
    condition     = aws_ecr_repository_creation_template.default["ecrpub"].image_tag_mutability == "IMMUTABLE_WITH_EXCLUSION"
    error_message = "Expected image_tag_mutability to be IMMUTABLE_WITH_EXCLUSION."
  }

  assert {
    condition     = aws_ecr_repository_creation_template.default["ecrpub"].image_tag_mutability_exclusion_filter[0].filter == "latest"
    error_message = "Expected an exclusion filter for latest."
  }
}

run "exclusion_filter_requires_immutable_with_exclusion" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  variables {
    image_tag_mutability = "MUTABLE"

    image_tag_mutability_exclusion_filter = [
      {
        filter      = "latest"
        filter_type = "WILDCARD"
      },
    ]
  }

  expect_failures = [
    var.image_tag_mutability,
  ]
}

run "exclusion_filter_type_must_be_wildcard" {
  command = plan

  module {
    source = "./modules/pull-through-cache"
  }

  variables {
    image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

    image_tag_mutability_exclusion_filter = [
      {
        filter      = "latest"
        filter_type = "REGEX"
      },
    ]
  }

  expect_failures = [
    var.image_tag_mutability_exclusion_filter,
  ]
}
