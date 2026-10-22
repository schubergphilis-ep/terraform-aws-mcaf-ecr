# terraform-aws-mcaf-ecr

Terraform module to setup and manage AWS Elastic Container Registry (ECR) repositories.

IMPORTANT: We do not pin modules to versions in our examples. We highly recommend that in your code you pin the version to the exact version you are using so that your infrastructure remains stable.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.8.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecr_lifecycle_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_lifecycle_policy) | resource |
| [aws_ecr_repository.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repository_names"></a> [repository\_names](#input\_repository\_names) | list of repository names, names can include namespaces: prefixes ending with a slash (/) | `list(string)` | n/a | yes |
| <a name="input_additional_ecr_policy_statements"></a> [additional\_ecr\_policy\_statements](#input\_additional\_ecr\_policy\_statements) | Map of additional ecr repository policy statements | <pre>map(object({<br/>    effect = string<br/>    principal = object({<br/>      type        = string<br/>      identifiers = list(string)<br/>    })<br/>    actions = list(string)<br/>    condition = optional(list(object({<br/>      test     = string<br/>      variable = string<br/>      values   = list(string)<br/>    })), [])<br/>  }))</pre> | `null` | no |
| <a name="input_custom_lifecycle_policy_rules"></a> [custom\_lifecycle\_policy\_rules](#input\_custom\_lifecycle\_policy\_rules) | JSON definition of custom policy Rules, this will disable the default policy | `string` | `null` | no |
| <a name="input_enable_lifecycle_policy"></a> [enable\_lifecycle\_policy](#input\_enable\_lifecycle\_policy) | Set to false to prevent the module from adding any lifecycle policies to any repositories | `bool` | `true` | no |
| <a name="input_force_delete"></a> [force\_delete](#input\_force\_delete) | When deleting a repository, force the deletion if it is not empty | `bool` | `false` | no |
| <a name="input_image_tag_mutability"></a> [image\_tag\_mutability](#input\_image\_tag\_mutability) | The tag mutability setting for the repository. Must be: `MUTABLE`, `IMMUTABLE`, `IMMUTABLE_WITH_EXCLUSION` or `MUTABLE_WITH_EXCLUSION` | `string` | `"IMMUTABLE"` | no |
| <a name="input_image_tag_mutability_exclusion_filter"></a> [image\_tag\_mutability\_exclusion\_filter](#input\_image\_tag\_mutability\_exclusion\_filter) | List of image tag filters excluded from the `image_tag_mutability` setting. Wildcards (`*`) are supported, e.g. `latest` or `v*` | `list(string)` | `[]` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The KMS key ARN used for the repository encryption | `string` | `null` | no |
| <a name="input_principals_readonly_access"></a> [principals\_readonly\_access](#input\_principals\_readonly\_access) | Principal ARNs to provide with readonly access to the ECR | `list(string)` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | The AWS region where resources will be created; if omitted the default provider region is used | `string` | `null` | no |
| <a name="input_repository_tags"></a> [repository\_tags](#input\_repository\_tags) | Mapping of tags for a repository using repository name as key | `map(map(string))` | `{}` | no |
| <a name="input_scan_images_on_push"></a> [scan\_images\_on\_push](#input\_scan\_images\_on\_push) | Indicates if images are automatically scanned after being pushed to the repository | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Mapping of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arns"></a> [arns](#output\_arns) | n/a |
| <a name="output_repository_url"></a> [repository\_url](#output\_repository\_url) | n/a |
<!-- END_TF_DOCS -->

## Licensing

100% Open Source and licensed under the Apache License Version 2.0. See [LICENSE](https://github.com/schubergphilis/terraform-aws-mcaf-ecr/blob/master/LICENSE) for full details.
