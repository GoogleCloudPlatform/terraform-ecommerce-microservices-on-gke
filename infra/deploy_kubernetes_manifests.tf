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

// This file deploys a Kubernetes Job to the config cluster.
// That Job will deploy Kubernetes resources to all clusters.

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  k8s_deployer_namespace    = "default"
  k8s_service_account_name  = "k8s-manifests-deployer-service-account"
  google_service_account_id = "k8s-manifests-deployer${var.resource_name_suffix}"
}

// Connect a Kubernetes provider to the config cluster.
provider "kubernetes" {
  host                   = "https://${google_container_cluster.my_cluster_config.endpoint}"
  username               = google_container_cluster.my_cluster_config.master_auth.0.username
  password               = google_container_cluster.my_cluster_config.master_auth.0.password
  client_certificate     = base64decode(google_container_cluster.my_cluster_config.master_auth[0].cluster_ca_certificate)
  cluster_ca_certificate = base64decode(google_container_cluster.my_cluster_config.master_auth[0].client_certificate)
  client_key             = base64decode(google_container_cluster.my_cluster_config.master_auth[0].client_key)
  alias                  = "kubernetes_provider"
}

// Kubernetes (K8s) Job inside the cluser that deploys K8s resources to all clusters.
resource "kubernetes_job" "kubernetes_manifests_deployer_job" {
  provider = kubernetes.kubernetes_provider
  metadata {
    name      = "kubernetes-manifests-deployer-job"
    namespace = var.k8s_deployer_namespace
  }
  spec {
    completions = 1
    template {
      metadata {}
      spec {
        service_account_name = local.k8s_service_account_name
        container {
          name  = "kubernetes-manifests-deployer"
          image = "us-docker.pkg.dev/google-samples/containers/gke/kubernetes-manifests-deployer:v0.0.0"
          env {
            name  = "PROJECT_ID"
            value = var.project_id
          }
          env {
            name  = "RESOURCE_NAME_SUFFIX"
            value = var.resource_name_suffix
          }
          resources {
            limits = {
              cpu    = "250m"
              memory = "128Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "64Mi"
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true
  timeouts {
    create = "600s"
  }
  depends_on = [
    google_project_iam_member.google_service_account_is_kubernetes_admin,
    google_service_account_iam_member.allow_kubernetes_sa_to_impersonate_google_cloud_sa,
    kubernetes_service_account.kubernetes_manifests_deployer_service_account
  ]
}

// Kubernetes Service Account (different from the Google Cloud Service Account).
resource "kubernetes_service_account" "kubernetes_manifests_deployer_service_account" {
  provider = kubernetes.kubernetes_provider
  metadata {
    name      = local.k8s_service_account_name
    namespace = var.k8s_deployer_namespace
    annotations = {
      "iam.gke.io/gcp-service-account" = google_service_account.kubernetes_manifests_deployer_service_account.email
    }
  }
}

// The Google Cloud Service Account.
resource "google_service_account" "kubernetes_manifests_deployer_service_account" {
  project      = var.project_id
  account_id   = local.google_service_account_id
  display_name = "Kubernetes Manifests Deployer"
  depends_on = [
    module.enable_google_apis
  ]
}

// The Google Cloud Service Account needs to administer Kubernetes resource in all clusters.
resource "google_project_iam_member" "google_service_account_is_kubernetes_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.kubernetes_manifests_deployer_service_account.email}"
}

// Allow the Kubernetes Service Account to impersonate the Google Cloud Service Account.
resource "google_service_account_iam_member" "allow_kubernetes_sa_to_impersonate_google_cloud_sa" {
  service_account_id = google_service_account.kubernetes_manifests_deployer_service_account.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "serviceAccount:${var.project_id}.svc.id.goog[${var.k8s_deployer_namespace}/${local.k8s_service_account_name}]"
  depends_on = [
    kubernetes_service_account.kubernetes_manifests_deployer_service_account
  ]
}
