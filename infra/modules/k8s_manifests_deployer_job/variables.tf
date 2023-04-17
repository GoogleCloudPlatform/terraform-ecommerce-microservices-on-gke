# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

variable "cluster_host" {
  type        = string
  description = "Endpoint of the cluster to which the Kubernetes Job will be deployed"
  sensitive   = true
}

variable "cluster_ca_certificate" {
  type        = string
  description = "Certificate used by the `kubernetes` Terraform provider for TLS authentication"
  sensitive   = true
}

variable "cluster_client_certificate" {
  type        = string
  description = "Client certificate used by the 'kubernetes' Terraform provider for TLS authentication"
  sensitive   = true
}

variable "cluster_client_key" {
  type        = string
  description = "Client key used by the 'kubernetes' Terraform provider for TLS authentication"
  sensitive   = true
}

variable "kubernetes_namespace" {
  type        = string
  default     = "default"
  description = "The Kubernetes Namespace inside which the Kubernetes Job and ServiceAccount will be deployed"
}

variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "resource_name_suffix" {
  type        = string
  description = "Optional string added to the end of GCP resource names, allowing GCP project reuse"
}
