/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// Enable access to the configuration of the Google Cloud provider.
data "google_client_config" "default" {}

// Deploy a Kubernetes Job to the config cluster.
// That Job will deploy Kubernetes resources to all clusters.
module "k8s_manifests_deployer_job" {
  source               = "./modules/k8s_manifests_deployer_job"
  project_id           = var.project_id
  resource_name_suffix = var.resource_name_suffix
  cluster_host         = "https://${resource.google_container_cluster.my_cluster_config.endpoint}"
  cluster_token        = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(
    resource.google_container_cluster.my_cluster_config.master_auth[0].cluster_ca_certificate,
  )
}
