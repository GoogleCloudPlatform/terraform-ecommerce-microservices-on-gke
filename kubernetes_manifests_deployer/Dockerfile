# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This Docker image is available a URL similar to: us-docker.pkg.dev/google-samples/containers/gke/kubernetes-manifests-deployer:vX.Y.Z

# Some commands needed for the shell scripts: gcloud, kubectl, sed.
FROM google/cloud-sdk:493.0.0-alpine@sha256:a2f9df8f858fc51f216561ea24f22b1fd35f348be686ed6647a17237813c4119
RUN gcloud components install kubectl gke-gcloud-auth-plugin

WORKDIR /app

COPY kubernetes_manifests/ kubernetes_manifests/
COPY deploy_k8s_resources.sh deploy_k8s_resources.sh
COPY deploy_single_cluster_k8s_resources.sh deploy_single_cluster_k8s_resources.sh
COPY deploy_multi_cluster_k8s_resources.sh deploy_multi_cluster_k8s_resources.sh

# The bash scripts should be executable.
RUN ["chmod", "+x", "/app/deploy_k8s_resources.sh"]
RUN ["chmod", "+x", "/app/deploy_single_cluster_k8s_resources.sh"]
RUN ["chmod", "+x", "/app/deploy_multi_cluster_k8s_resources.sh"]

ENTRYPOINT ./deploy_k8s_resources.sh "${PROJECT_ID}" "${RESOURCE_NAME_SUFFIX}" "kubernetes_manifests/"
