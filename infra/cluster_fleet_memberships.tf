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

resource "google_gke_hub_membership" "my_fleet_membership_usa" {
  membership_id = "my-fleet-membership-usa${var.resource_name_suffix}"
  project       = var.project_id
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.my_cluster_usa.id}"
    }
  }
  depends_on = [
    module.enable_multi_cluster_google_apis
  ]
  provider = google-beta
}

resource "google_gke_hub_membership" "my_fleet_membership_europe" {
  membership_id = "my-fleet-membership-europe${var.resource_name_suffix}"
  project       = var.project_id
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.my_cluster_europe.id}"
    }
  }
  depends_on = [
    module.enable_multi_cluster_google_apis
  ]
  provider = google-beta
}

resource "google_gke_hub_membership" "my_fleet_membership_config" {
  membership_id = "my-fleet-membership-config${var.resource_name_suffix}"
  project       = var.project_id
  endpoint {
    gke_cluster {
      resource_link = "//container.googleapis.com/${google_container_cluster.my_cluster_config.id}"
    }
  }
  depends_on = [
    module.enable_multi_cluster_google_apis
  ]
  provider = google-beta
}
