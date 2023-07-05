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
