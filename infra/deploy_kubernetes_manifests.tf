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

resource "null_resource" "deploy_single_cluster_k8s_resources" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "chmod +x ${path.module}/deploy_single_cluster_k8s_resources.sh;${path.module}/deploy_single_cluster_k8s_resources.sh ${var.project_id} ${var.resource_name_suffix} ${path.module}/../kubernetes_manifests"
  }
  depends_on = [
    resource.google_container_cluster.my_cluster_canada,
    resource.google_container_cluster.my_cluster_config,
    resource.google_container_cluster.my_cluster_usa,
  ]
}

resource "null_resource" "deploy_multi_cluster_k8s_resources" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "chmod +x ${path.module}/deploy_multi_cluster_k8s_resources.sh;${path.module}/deploy_multi_cluster_k8s_resources.sh ${var.project_id} ${var.resource_name_suffix} ${path.module}/../kubernetes_manifests"
  }
  depends_on = [
    resource.google_project_iam_member.gke_mcs_importer_iam_binding,
    resource.null_resource.deploy_single_cluster_k8s_resources,
  ]
}
