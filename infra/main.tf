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

provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

module "enable_base_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 14.0"
  disable_services_on_destroy = false
  activate_apis = [
    "cloudresourcemanager.googleapis.com",
    "container.googleapis.com",
    "iam.googleapis.com",
  ]
  project_id = var.project_id
}

module "enable_multi_cluster_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 14.0"
  disable_services_on_destroy = false
  activate_apis = [
    "gkehub.googleapis.com",
    "multiclusteringress.googleapis.com",
    "multiclusterservicediscovery.googleapis.com",
    "trafficdirector.googleapis.com",
  ]
  project_id = var.project_id
}

# Assign a custom service account to the 3 GKE clusters
# because some users' projects will not have the default Compute Engine service account enabled.
resource "google_service_account" "my_service_account" {
  account_id   = "my-service-account${var.resource_name_suffix}"
  display_name = "My Service Account"
  depends_on = [
    module.enable_base_google_apis
  ]
}

resource "google_project_iam_member" "my_service_account_role_metric_writer" {
  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "my_service_account_role_log_writer" {
  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "my_service_account_role_monitoring_viewer" {
  project = var.project_id
  role    = "roles/monitoring.viewer"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_project_iam_member" "my_service_account_role_stackdriver_writer" {
  project = var.project_id
  role    = "roles/stackdriver.resourceMetadata.writer"
  member  = "serviceAccount:${google_service_account.my_service_account.email}"
}

resource "google_container_cluster" "my_cluster_usa" {
  name             = "my-cluster-usa${var.resource_name_suffix}"
  location         = "us-west1"
  enable_autopilot = true
  project          = var.project_id
  resource_labels  = var.labels
  depends_on = [
    module.enable_base_google_apis
  ]
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.my_service_account.email
    }
  }
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
  provider = google-beta # Needed for the google_gkehub_feature Terraform module.
}

resource "google_container_cluster" "my_cluster_europe" {
  name             = "my-cluster-europe${var.resource_name_suffix}"
  location         = "europe-west1"
  enable_autopilot = true
  project          = var.project_id
  resource_labels  = var.labels
  depends_on = [
    module.enable_base_google_apis
  ]
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.my_service_account.email
    }
  }
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
  provider = google-beta # Needed for the google_gkehub_feature Terraform module.
}

resource "google_container_cluster" "my_cluster_config" {
  name             = "my-cluster-config${var.resource_name_suffix}"
  location         = "us-west1"
  enable_autopilot = true
  project          = var.project_id
  resource_labels  = var.labels
  depends_on = [
    module.enable_base_google_apis
  ]
  cluster_autoscaling {
    auto_provisioning_defaults {
      service_account = google_service_account.my_service_account.email
    }
  }
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
  provider = google-beta # Needed for the google_gkehub_feature Terraform module.
}
