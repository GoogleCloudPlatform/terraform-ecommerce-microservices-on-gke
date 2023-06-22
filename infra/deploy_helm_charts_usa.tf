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

// Recreate the existing helm_provider_usa.tf file so that the
// credentials to the cluster are hard-coded.
data "template_file" "helm_provider_usa" {
  template = file("${path.module}/helm_provider.tf.template")
  vars = {
    helm_provider_alias    = "helm_provider_for_my_cluster_usa"
    cluster_host           = "https://${google_container_cluster.my_cluster_usa.endpoint}"
    cluster_ca_certificate = base64decode(google_container_cluster.my_cluster_usa.master_auth[0].cluster_ca_certificate)
  }
  depends_on = [
    google_container_cluster.my_cluster_usa
  ]
}
resource "local_sensitive_file" "helm_provider_usa" {
  content  = data.template_file.helm_provider_usa.rendered
  filename = "${path.module}/helm_provider_usa.tf"
  lifecycle {
    ignore_changes = [
      content,
      filename,
      directory_permission,
      file_permission,
    ]
  }
  depends_on = [
    google_container_cluster.my_cluster_usa
  ]
}

resource "helm_release" "helm_chart_redis_cart_service_export" {
  provider  = helm.helm_provider_for_my_cluster_usa
  name      = "helm-chart-redis-cart-service-export"
  chart     = "${path.module}/helm_chart_redis_cart_service_export"
  namespace = "cartservice"
  depends_on = [
    kubernetes_job.kubernetes_manifests_deployer_job, # This allows us to wait for the ServiceExport CRD.
    time_sleep.wait_after_destroying_mci_k8s_and_before_destroying_mci_feature
  ]
}
