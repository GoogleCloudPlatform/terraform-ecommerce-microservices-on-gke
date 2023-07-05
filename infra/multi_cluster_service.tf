resource "google_project_iam_member" "my_service_account_role_network_viewer" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
  depends_on = [
    module.enable_base_google_apis
  ]
}

resource "google_compute_global_address" "multi_cluster_ingress_ip_address" {
  provider     = google-beta
  name         = "multi-cluster-ingress-ip-address${var.resource_name_suffix}"
  address_type = "EXTERNAL"
  project      = var.project_id
  depends_on = [
    module.enable_base_google_apis
  ]
}

resource "google_gke_hub_feature" "multi_cluster_ingress_feature" {
  name     = "multiclusteringress"
  location = "global"
  project  = var.project_id
  spec {
    multiclusteringress {
      // This is normally the config cluster. But I'm temporarily using the Europe cluster.
      config_membership = google_gke_hub_membership.my_fleet_membership_europe.id
    }
  }
  provider = google-beta
  depends_on = [
    module.enable_multi_cluster_google_apis
  ]
}

resource "google_project_iam_member" "gke_mcs_importer_iam_binding" {
  project = var.project_id
  role    = "roles/compute.networkViewer"
  member  = "serviceAccount:${var.project_id}.svc.id.goog[gke-mcs/gke-mcs-importer]"
  depends_on = [
    resource.google_gke_hub_feature.multi_cluster_ingress_feature
  ]
}
