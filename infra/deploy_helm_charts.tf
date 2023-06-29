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

# Enable access to the configuration of the Google Cloud provider.
data "google_client_config" "default" {}

provider "helm" {
  alias = "helm_provider_for_my_cluster_config"
  kubernetes {
    host                   = "https://${google_container_cluster.my_cluster_config.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster_config.master_auth[0].cluster_ca_certificate)
  }
}

provider "helm" {
  alias = "helm_provider_for_my_cluster_usa"
  kubernetes {
    host                   = "https://${google_container_cluster.my_cluster_usa.endpoint}"
    token                  = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster_usa.master_auth[0].cluster_ca_certificate)
  }
}

resource "helm_release" "helm_chart_multi_cluster_ingress" {
  provider  = helm.helm_provider_for_my_cluster_config
  name      = "helm-chart-multi-cluster-ingress"
  chart     = "${path.module}/helm_chart_multi_cluster_ingress"
  namespace = "frontend"
  set {
    name  = "projectId"
    value = var.project_id
  }
  set {
    name  = "resourceNameSuffix"
    value = var.resource_name_suffix
  }
  depends_on = [
    kubernetes_job.kubernetes_manifests_deployer_job, # This allows us to wait for the MCI CRDs.
    time_sleep.wait_after_destroying_mci_k8s_and_before_destroying_mci_feature
  ]
}

resource "helm_release" "helm_chart_redis_cart" {
  provider  = helm.helm_provider_for_my_cluster_usa
  name      = "helm-chart-redis-cart"
  chart     = "${path.module}/helm_chart_redis_cart"
  namespace = "cartservice"
  depends_on = [
    kubernetes_job.kubernetes_manifests_deployer_job, # This allows us to wait for the ServiceExport CRD.
    time_sleep.wait_after_destroying_mci_k8s_and_before_destroying_mci_feature
  ]
}

resource "time_sleep" "wait_after_destroying_mci_k8s_and_before_destroying_mci_feature" {
  destroy_duration = "300s"
  depends_on = [
    google_gke_hub_feature.multi_cluster_ingress_feature
  ]
}
