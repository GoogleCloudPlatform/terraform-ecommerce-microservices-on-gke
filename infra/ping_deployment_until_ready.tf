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

# Force "terraform apply" to wait until the deployment IP address successfully serves the app.
# tflint-ignore: terraform_unused_declarations
data "http" "ping_deployment_until_ready" {
  count  = var.should_wait_until_deployment_ready ? 1 : 0
  url    = "http://${resource.google_compute_global_address.multi_cluster_ingress_ip_address.address}"
  method = "HEAD" # There's no point GET-ing the full body.
  retry {
    attempts     = 60
    max_delay_ms = 1000 * 10
    min_delay_ms = 1000 * 10
  }
  depends_on = [
    # There's no point pinging until all resources have been applied.
    # So let's wait until the very last resource has been provisioned.
    resource.helm_release.helm_chart_multi_cluster_ingress
  ]
}
