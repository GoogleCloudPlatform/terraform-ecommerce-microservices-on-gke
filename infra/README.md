# Ecommerce web app deployed on Kubernetes

This GitHub repository contains the Terraform and Kubernetes YAML used by the Jump Start Solution (JSS) entitled [_Ecommerce web app deployed on Kubernetes_](https://console.cloud.google.com/products/solutions/details/ecomm-microservices), available on Google Cloud.

The [Deploy this solution](#deploy-this-solution) section below contains a brief summary of how you can deploy this solution to your Google Cloud project. For more detailed instructions including troubleshooting guidance, see the [solution guide](https://cloud.google.com/architecture/application-development/ecommerce-microservices).

## What's deployed?

The following is a description of what's deployed by this solution:
1. **Cymbal Shops**: This solution deploys a demo application called [Cymbal Shops](https://github.com/GoogleCloudPlatform/microservices-demo) (also known as Online Boutique). Cymbal Shops consists of about 10 microservices. The source code of each microservice is available in a [separate, open source GitHub repository](https://github.com/GoogleCloudPlatform/microservices-demo).
1. **3 Google Kubernetes Engine (GKE) clusters**: This solution provisions a total of 3 GKE cluster — 2 clusters in the US, and 1 cluster in Europe. One of the US clusters will be used for configuring multi-cluster ingress, while the other 2 clusters will host the microservices of the Cymbal Shops application (including the frontend microservice).
1. **Static external IP address**: The Cymbal Shops application will be pubicly acessible via an IP address, reserved and output (into your command line interface) by the Terraform. The IP address may take about 5 minutes to actually serve the frontend since multi-cluster ingress takes a few minutes to warm up.
1. **Single Redis _cart_ database**: The items in users' carts are managed in a single Redis databases, only deployed to a US cluster — for data consistency.

<img src="./docs/architectural-diagram.png" alt="Architectural diagram showing the Cymbal Shops application's microservices deployed into 2 GKE clusters — one in the US, and one in Europe. A third cluster in the US contains Kubernetes resources for MultiClusterIngress and MultiClusterService." height="650" />

To learn more about the deployed infrastructure, read the [solution guide on cloud.google.com](https://cloud.google.com/architecture/application-development/ecommerce-microservices).

## Deploy this solution

The best way to deploy this solution is through the [Jump Start Solutions page](https://console.cloud.google.com/products/solutions/details/ecomm-microservices) on Google Cloud Console. But if you specifically want to deploy the Terraform inside this git branch or commit, follow the instructions below.

### Prerequisites

* A terminal environment with the following CLI tools available:
  * `terraform`
  * `gcloud`
* A Google Cloud project that is **not** currently using a [Multi Cluster Ingress](https://cloud.google.com/kubernetes-engine/docs/concepts/multi-cluster-ingress#architecture).

### Steps

#### 1. Clone this git repository.

```
git clone https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke
```

#### 2. Go into the `infra/` folder.

```
cd terraform-ecommerce-microservices-on-gke/infra
```

The `infra/` directory contains all the Terraform code for this solution.

#### 3. Run the Terraform.

```
terraform init
terraform apply -var 'project_id=MY_PROJECT_ID'
```

Replace `MY_PROJECT_ID` with your [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) ID. We recommend creating a new project so you can easily clean up all resources by deleting the entire project.

You may need to type "Yes", after you run `terraform apply`.

#### 4. Report any bugs as a GitHub Issue.

a. Search the [existing list of GitHub issues](https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke/issues?q=is%3Aissue).

b. If there isn't already a GitHub issue for your bug, [create a new GitHub issue](https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke/issues/new/choose).

#### 5. Get the IP address of the deployment.

Get the external IP address where Cymbal Shops will be accessible about 5 minutes _after_ `terraform apply` successfully completes:

```
gcloud compute addresses list \
    --filter="name=('multi-cluster-ingress-ip-address-1')" \
    --project=MY_PROJECT_ID
```

Replace `MY_PROJECT_ID` with your [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) ID.

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| labels | A set of key/value label pairs to assign to the resources deployed by this blueprint. | `map(string)` | `{}` | no |
| project\_id | The Google Cloud project ID. | `string` | n/a | yes |
| resource\_name\_suffix | Optional string added to the end of resource names, allowing project reuse.<br>  This should be short and only contain dashes, lowercase letters, and digits.<br>  It shoud not end with a dash. | `string` | `"-1"` | no |

## Outputs

| Name | Description |
|------|-------------|
| deployment\_ip\_address | Public IP address of the deployment |
| neos\_toc\_url | Neos Tutorial URL |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Contributing

If you would like to contribute to this repository, read [CONTRIBUTING](CONTRIBUTING.md).

Please note that this project is released with a Contributor Code of Conduct. By participating in
this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more
information.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
