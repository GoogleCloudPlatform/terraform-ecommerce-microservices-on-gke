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

locals {
  cluster_usa_name    = google_container_cluster.my_cluster_usa.name
  cluster_canada_name = google_container_cluster.my_cluster_canada.name
  cluster_config_name = google_container_cluster.my_cluster_config.name
}

module "enable_google_apis" {
  source                      = "terraform-google-modules/project-factory/google//modules/project_services"
  version                     = "~> 14.0"
  disable_services_on_destroy = false
  activate_apis               = ["container.googleapis.com"]
  project_id                  = var.project_id
}

resource "google_container_cluster" "my_cluster_usa" {
  name             = "my-cluster-usa"
  location         = "us-west1"
  enable_autopilot = true
  depends_on = [
    module.enable_google_apis
  ]
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
}

resource "google_container_cluster" "my_cluster_canada" {
  name             = "my-cluster-canada"
  location         = "northamerica-northeast1"
  enable_autopilot = true
  depends_on = [
    module.enable_google_apis
  ]
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
}

resource "google_container_cluster" "my_cluster_config" {
  name             = "my-cluster-config"
  location         = "us-west1"
  enable_autopilot = true
  depends_on = [
    module.enable_google_apis
  ]
  # Need an empty ip_allocation_policy to overcome an error related to autopilot node pool constraints.
  # Workaround from https://github.com/hashicorp/terraform-provider-google/issues/10782#issuecomment-1024488630
  ip_allocation_policy {
  }
}
