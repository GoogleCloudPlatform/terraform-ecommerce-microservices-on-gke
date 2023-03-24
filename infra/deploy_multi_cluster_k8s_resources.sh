# Script parameters
PROJECT_ID=$1
RESOURCE_NAME_SUFFIX=$2

CLUSTER_CONTEXT_CONFIG=gke_${PROJECT_ID}_us-west1_my-cluster-config${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_USA=gke_${PROJECT_ID}_us-west1_my-cluster-usa${RESOURCE_NAME_SUFFIX}
K8S_MANIFESTS_DIR=../kubernetes_manifests

# Deploy Multi Cluster Ingress configuration.
sed -i "s/RESOURCE_NAME_SUFFIX/${RESOURCE_NAME_SUFFIX}/g" ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  apply -f ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml

# Deploy the redis-cart Service into the US cluster.
# This redis-cart Service gets exported to the other clusters.
kubectl --context=${CLUSTER_CONTEXT_USA} \
  apply -f ${K8S_MANIFESTS_DIR}/redis_cart/
