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

resource "google_project_iam_member" "my_service_account_role_network_viewer" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
  depends_on = [
    module.enable_google_apis
  ]
}

resource "google_compute_global_address" "multi_cluster_ingress_ip_address" {
  provider     = google-beta
  name         = "multi-cluster-ingress-ip-address"
  address_type = "EXTERNAL"
  project      = var.project_id
  depends_on = [
    module.enable_google_apis
  ]
}

resource "google_gke_hub_feature" "multi_cluster_ingress_feature" {
  name     = "multiclusteringress"
  location = "global"
  project  = var.project_id
  spec {
    multiclusteringress {
      config_membership = "my-fleet-membership-config${var.resource_name_suffix}"
    }
  }
  depends_on = [
    module.enable_google_apis
  ]
  provider = google-beta
}

resource "google_project_iam_member" "gke_mcs_importer_iam_binding" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[gke-mcs/gke-mcs-importer]"
  depends_on = [
    resource.google_gke_hub_feature.multi_cluster_ingress_feature
  ]
}
