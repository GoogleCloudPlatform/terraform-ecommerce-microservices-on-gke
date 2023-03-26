# Script parameters
PROJECT_ID=$1
RESOURCE_NAME_SUFFIX=$2

CLUSTER_CONTEXT_CANADA=gke_${PROJECT_ID}_northamerica-northeast1_my-cluster-canada${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_CONFIG=gke_${PROJECT_ID}_us-west1_my-cluster-config${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_USA=gke_${PROJECT_ID}_us-west1_my-cluster-usa${RESOURCE_NAME_SUFFIX}
K8S_MANIFESTS_DIR=../kubernetes_manifests

# Deploy Multi Cluster Ingress configuration.
sed -i "s/RESOURCE_NAME_SUFFIX/${RESOURCE_NAME_SUFFIX}/g" ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml
echo 'Waiting for MutliClusterService CRD & MultiClusterIngress CRD...'
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  --namespace frontend \
  wait --for condition=established --timeout=60s crd/multiclusterservice.networking.gke.io
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  --namespace frontend \
  wait --for condition=established --timeout=60s crd/multiclusteringress.networking.gke.io
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  apply -f ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml

# Deploy the redis-cart Service into the US cluster.
# This redis-cart Service gets exported to the other clusters.
echo 'Waiting for ServiceExport CRD...'
kubectl --context=${CLUSTER_CONTEXT_USA} \
  --namespace cartservice \
  wait --for condition=established --timeout=120s crd/serviceexports.net.gke.io
kubectl --context=${CLUSTER_CONTEXT_USA} \
  apply -f ${K8S_MANIFESTS_DIR}/redis_cart/

# Update the address of the redis-cart used in the Canada cluster.
sed -i "s/redis-cart.cartservice:6379/redis-cart.cartservice.svc.clusterset.local:6379/g" \
  ${K8S_MANIFESTS_DIR}/cartservice/cartservice.yaml
kubectl --context=${CLUSTER_CONTEXT_CANADA} \
  --namespace=cartservice \
  apply -f ${K8S_MANIFESTS_DIR}/cartservice/cartservice.yaml
