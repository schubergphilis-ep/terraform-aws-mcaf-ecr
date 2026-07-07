# ECR Pull-Through Cache Setup

This module creates cache rules, registry policy and repository creation template for ECR.

Sample creation of a github pull through cache is under examples/pull-through-cache.

For the pull through cache rules configuration, a sample of the most common registries can be found below:

```hcl
{
  ecrpub = {
    ecr_repository_prefix = "ecr-public"
    upstream_registry_url = "public.ecr.aws"
  }
  github = {
    ecr_repository_prefix = "github-public"
    upstream_registry_url = "ghcr.io"
  }
  k8s = {
    ecr_repository_prefix = "k8s-public"
    upstream_registry_url = "registry.k8s.io"
  }
  quay = {
    ecr_repository_prefix = "quay-public"
    upstream_registry_url = "quay.io"
  }
}

```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ecr_repo_creation_template_role"></a> [ecr\_repo\_creation\_template\_role](#module\_ecr\_repo\_creation\_template\_role) | schubergphilis-ep/mcaf-role/aws | ~> 0.5.3 |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_pull_through_cache_rule.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_registry_policy.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
| [aws_ecr_repository_creation_template.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_creation_template) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.creation_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecr_repo_creation_template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.registry](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#input\_pull\_through\_cache\_rules) | List of pull through cache rules to create | <pre>map(object({<br/>    credential_arn        = optional(string)<br/>    description           = string<br/>    ecr_repository_prefix = string<br/>    upstream_registry_url = string<br/>  }))</pre> | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Determines whether resources will be created (affects all resources) | `bool` | `true` | no |
| <a name="input_create_ecr_repository_creation_role"></a> [create\_ecr\_repository\_creation\_role](#input\_create\_ecr\_repository\_creation\_role) | Create the IAM role used as a template for ECR repository creation. | `bool` | `true` | no |
| <a name="input_create_registry_policy"></a> [create\_registry\_policy](#input\_create\_registry\_policy) | Determines whether a registry policy will be created | `bool` | `false` | no |
| <a name="input_custom_ecr_repository_creation_role_arn"></a> [custom\_ecr\_repository\_creation\_role\_arn](#input\_custom\_ecr\_repository\_creation\_role\_arn) | Custom role ARN for the creation template | `string` | `null` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The KMS key used for encryption | `string` | `null` | no |
| <a name="input_permissions_boundary"></a> [permissions\_boundary](#input\_permissions\_boundary) | Name of Permissions Boundary, including path. (e.g. /ep/workload\_boundary) | `string` | `null` | no |
| <a name="input_readonly_principals"></a> [readonly\_principals](#input\_readonly\_principals) | List of AWS account IDs. Account IDs (12 digits) will be converted to `arn:aws:iam::<account-id>:root`. | `list(string)` | `[]` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | The resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_pull_through_cache_rules"></a> [ecr\_pull\_through\_cache\_rules](#output\_ecr\_pull\_through\_cache\_rules) | Map of ECR pull through cache rules created |
| <a name="output_ecr_registry_policy_id"></a> [ecr\_registry\_policy\_id](#output\_ecr\_registry\_policy\_id) | ECR registry policy resource id |
| <a name="output_ecr_repository_creation_templates"></a> [ecr\_repository\_creation\_templates](#output\_ecr\_repository\_creation\_templates) | Map of ECR repository creation templates |
<!-- END_TF_DOCS -->