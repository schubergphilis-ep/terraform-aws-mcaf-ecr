mock_provider "aws" {
  # Policy arguments are validated as JSON, even with a mocked provider.
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

variables {
  repository_names = ["image-x", "team/image-y"]
}

run "no_policy_by_default" {
  command = plan

  assert {
    condition     = length(data.aws_iam_policy_document.default) == 0
    error_message = "Expected no policy document without readonly principals or additional statements, got ${length(data.aws_iam_policy_document.default)}."
  }

  assert {
    condition     = length(aws_ecr_repository_policy.default) == 0
    error_message = "Expected no repository policy by default, got ${jsonencode(keys(aws_ecr_repository_policy.default))}."
  }
}

run "cross_account_readonly" {
  command = plan

  variables {
    principals_readonly_access = ["111111111111", "222222222222"]
  }

  assert {
    condition     = keys(aws_ecr_repository_policy.default) == ["image-x", "team/image-y"]
    error_message = "Expected one repository policy per repository, got ${jsonencode(keys(aws_ecr_repository_policy.default))}."
  }

  assert {
    condition     = alltrue([for p in aws_ecr_repository_policy.default : p.policy == data.aws_iam_policy_document.default[0].json])
    error_message = "Expected every repository policy to be the rendered policy document."
  }

  assert {
    condition     = data.aws_iam_policy_document.default[0].statement[*].sid == tolist(["ReadonlyAccess"])
    error_message = "Expected only the ReadonlyAccess statement, got ${jsonencode(data.aws_iam_policy_document.default[0].statement[*].sid)}."
  }

  assert {
    condition     = data.aws_iam_policy_document.default[0].statement[0].effect == "Allow"
    error_message = "Expected the ReadonlyAccess statement to allow, got ${data.aws_iam_policy_document.default[0].statement[0].effect}."
  }

  assert {
    condition     = one(data.aws_iam_policy_document.default[0].statement[0].principals).type == "AWS"
    error_message = "Expected an AWS principal, got ${one(data.aws_iam_policy_document.default[0].statement[0].principals).type}."
  }

  assert {
    condition = one(data.aws_iam_policy_document.default[0].statement[0].principals).identifiers == toset([
      "arn:aws:iam::111111111111:root",
      "arn:aws:iam::222222222222:root",
    ])
    error_message = "Expected the account root ARNs as principals, got ${jsonencode(one(data.aws_iam_policy_document.default[0].statement[0].principals).identifiers)}."
  }

  assert {
    condition = length(setsubtract(
      ["ecr:BatchCheckLayerAvailability", "ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"],
      data.aws_iam_policy_document.default[0].statement[0].actions,
    )) == 0
    error_message = "Expected the pull actions, got ${jsonencode(data.aws_iam_policy_document.default[0].statement[0].actions)}."
  }

  assert {
    condition = length(setintersection(
      ["ecr:BatchDeleteImage", "ecr:CompleteLayerUpload", "ecr:InitiateLayerUpload", "ecr:PutImage", "ecr:UploadLayerPart"],
      data.aws_iam_policy_document.default[0].statement[0].actions,
    )) == 0
    error_message = "Expected no push or delete actions, got ${jsonencode(data.aws_iam_policy_document.default[0].statement[0].actions)}."
  }
}

run "readonly_and_additional_statement" {
  command = plan

  variables {
    principals_readonly_access = ["111111111111"]

    additional_ecr_policy_statements = {
      LambdaPull = {
        effect  = "allow"
        actions = ["ecr:BatchGetImage", "ecr:GetDownloadUrlForLayer"]

        principal = {
          type        = "Service"
          identifiers = ["lambda.amazonaws.com"]
        }

        condition = [{
          test     = "StringLike"
          variable = "aws:sourceArn"
          values   = ["arn:aws:lambda:eu-west-1:111111111111:function:*"]
        }]
      }
    }
  }

  assert {
    condition     = keys(aws_ecr_repository_policy.default) == ["image-x", "team/image-y"]
    error_message = "Expected one repository policy per repository, got ${jsonencode(keys(aws_ecr_repository_policy.default))}."
  }

  assert {
    condition     = toset(data.aws_iam_policy_document.default[0].statement[*].sid) == toset(["LambdaPull", "ReadonlyAccess"])
    error_message = "Expected the ReadonlyAccess and LambdaPull statements, got ${jsonencode(data.aws_iam_policy_document.default[0].statement[*].sid)}."
  }

  assert {
    condition = one(one([
      for s in data.aws_iam_policy_document.default[0].statement : s.principals if s.sid == "ReadonlyAccess"
    ])).identifiers == toset(["arn:aws:iam::111111111111:root"])
    error_message = "Expected the ReadonlyAccess statement to keep the account root principal."
  }

  assert {
    condition = one([
      for s in data.aws_iam_policy_document.default[0].statement : s.effect if s.sid == "LambdaPull"
    ]) == "Allow"
    error_message = "Expected the LambdaPull effect to be normalized to Allow."
  }

  assert {
    condition = alltrue([
      for c in one([for s in data.aws_iam_policy_document.default[0].statement : s.condition if s.sid == "LambdaPull"]) :
      c.test == "StringLike" && c.variable == "aws:sourceArn" && c.values == tolist(["arn:aws:lambda:eu-west-1:111111111111:function:*"])
    ]) && length(one([for s in data.aws_iam_policy_document.default[0].statement : s.condition if s.sid == "LambdaPull"])) == 1
    error_message = "Expected the LambdaPull statement to keep its condition, got ${jsonencode([for s in data.aws_iam_policy_document.default[0].statement : s.condition if s.sid == "LambdaPull"])}."
  }

  assert {
    condition = length(one([
      for s in data.aws_iam_policy_document.default[0].statement : s.condition if s.sid == "ReadonlyAccess"
    ])) == 0
    error_message = "Expected the ReadonlyAccess statement to have no condition."
  }
}
