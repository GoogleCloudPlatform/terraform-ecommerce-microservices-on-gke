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

// Recreate the existing helm_provider.tf file so that the
// credentials to the cluster are hard-coded.
data "template_file" "helm_provider" {
  template = file("${path.module}/helm_provider.tf.template")
  vars = {
    cluster_host           = "https://${google_container_cluster.my_cluster_config.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster_config.master_auth[0].cluster_ca_certificate)
  }
  depends_on = [
    google_container_cluster.my_cluster_config
  ]
}
resource "local_sensitive_file" "helm_provider" {
  content  = data.template_file.helm_provider.rendered
  filename = "${path.module}/helm_provider.tf"
  lifecycle {
    ignore_changes = [
      content,
      filename,
      directory_permission,
      file_permission,
    ]
  }
  depends_on = [
    google_container_cluster.my_cluster_config
  ]
}

resource "helm_release" "helm_chart_multi_cluster_ingress" {
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

resource "time_sleep" "wait_after_destroying_mci_k8s_and_before_destroying_mci_feature" {
  destroy_duration = "300s"
  depends_on = [
    google_gke_hub_feature.multi_cluster_ingress_feature
  ]
}
