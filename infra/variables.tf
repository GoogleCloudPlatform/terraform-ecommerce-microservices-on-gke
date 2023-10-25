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

variable "labels" {
  type        = map(string)
  default     = {}
  description = "A set of key/value label pairs to assign to the resources deployed by this blueprint."
}

variable "project_id" {
  type        = string
  description = "The Google Cloud project ID."
}

variable "resource_name_suffix" {
  type        = string
  default     = "-1"
  description = <<EOT
  Optional string added to the end of resource names, allowing project reuse.
  This should be short and only contain dashes, lowercase letters, and digits.
  It shoud not end with a dash.
  EOT
}

variable "should_wait_until_deployment_ready" {
  type        = string
  default     = true
  description = <<EOT
  Optional boolean which, when true, will make "terraform apply" wait until the deployment's
  IP address successfully serves the app (responds with a 2xx status).
  EOT
}
