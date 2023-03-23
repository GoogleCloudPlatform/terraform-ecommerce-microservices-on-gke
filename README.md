# Terraform Ecommerce Microservices on GKE

## Quickstart

Try out the Terraform in this repository.

#### 1. Clone this git repository.

```
git clone https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke
```

#### 2. Go into the `infra/` folder.

```
cd terraform-ecommerce-microservices-on-gke/infra
```

#### 3. Run the Terraform.

```
terraform init
terraform apply -var 'project_id=MY_PROJECT_ID'
```

Replace `MY_PROJECT_ID` with your [Google Cloud Project](https://cloud.google.com/resource-manager/docs/creating-managing-projects) ID. We recommend creating a new project so you can easily clean up all resources by deleting the entire project.

You may need to type "Yes", when after you run `terraform apply`.

#### 4. Report any bugs as a GitHub Issue.

a. Search the [existing list of GitHub](https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke/issues?q=is%3Aissue).

b. If there isn't already a GitHub issue for your bug, [create a new GitHub issue](https://github.com/GoogleCloudPlatform/terraform-ecommerce-microservices-on-gke/issues/new/choose).

#### 5. Get the IP address of the deployment.

We deployed 3 clusters — one of them is a [config cluster](https://cloud.google.com/kubernetes-engine/docs/concepts/multi-cluster-ingress#config_cluster_design). It can tell you the IP address of the deployment.

**a.** The config cluster's context is named similar to `my-project-id_us-west1_my-cluster-config`. Find the context:

```
kubectx | grep my-cluster-config
```

**b.** Replace `CONFIG_CLUSTER_CONTEXT` (in the command below) with the name of your config cluster, and get the IP address of deployment (that has been assigned to the `MultiClusterIngress`).

```
kubectl \
  --context=CONFIG_CLUSTER_CONTEXT \
  --namespace frontend \
  get MultiClusterIngress frontend-multi-cluster-ingress \
  --output jsonpath='{.status.VIP}'
```

## Contributing

If you would like to contribute to this repository, read [CONTRIBUTING](CONTRIBUTING.md).

Please note that this project is released with a Contributor Code of Conduct. By participating in
this project you agree to abide by its terms. See [Code of Conduct](CODE_OF_CONDUCT.md) for more
information.

## License

Apache 2.0 - See [LICENSE](LICENSE) for more information.
