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

resource "null_resource" "output_deployment_ip_address" {
  provisioner "local-exec" {
    interpreter = ["bash", "-exc"]
    command     = "chmod +x create_deployment_ip_address_file.sh;./create_deployment_ip_address_file.sh ${var.project_id} ${var.resource_name_suffix}"
  }
  depends_on = [
    resource.null_resource.deploy_multi_cluster_k8s_resources,
  ]
}

data "local_file" "deployment_ip_address_file" {
  filename = "${path.root}/deployment_ip_address_file"
  depends_on = [
    resource.null_resource.output_deployment_ip_address,
  ]
}

output "deployment_ip_address" {
  description = "Public IP address of the deployment"
  value       = data.local_file.deployment_ip_address_file
}
