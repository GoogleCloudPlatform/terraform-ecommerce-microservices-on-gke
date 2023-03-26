## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Google Cloud Project ID | `string` | n/a | yes |
| <a name="input_resource_name_suffix"></a> [resource\_name\_suffix](#input\_resource\_name\_suffix) | Optional string added to the end of GCP resource names, allowing GCP project reuse | `string` | `"-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_deployment_ip_address"></a> [deployment\_ip\_address](#output\_deployment\_ip\_address) | Public IP address of the deployment |
