# Script parameters
PROJECT_ID=$1
RESOURCE_NAME_SUFFIX=$2

CLUSTER_CONTEXT_CANADA=gke_${PROJECT_ID}_northamerica-northeast1_my-cluster-canada${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_CONFIG=gke_${PROJECT_ID}_us-west1_my-cluster-config${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_USA=gke_${PROJECT_ID}_us-west1_my-cluster-usa${RESOURCE_NAME_SUFFIX}
K8S_MANIFESTS_DIR=../kubernetes_manifests

wait_for_crd() {
  CRD=$1
  CLUSTER_CONTEXT=$2
  NAMESPACE=$3

  echo "Waiting for CRD ${CRD} to be created in cluster ${CLUSTER_CONTEXT}..."
  SECONDS_WAITED=0
  IS_CRD_CREATED=$(kubectl --context ${CLUSTER_CONTEXT} get crd/${CRD} -n=${NAMESPACE} 2>/dev/null)
  while [[(${IS_CRD_CREATED} == "") && ${SECONDS_WAITED} -lt 60 ]]; do
    IS_CRD_CREATED=$(kubectl --context ${CLUSTER_CONTEXT} get crd/${CRD} -n=${NAMESPACE} 2>/dev/null)
    sleep 1s
    SECONDS_WAITED=$((SECONDS_WAITED+1))
  done

  if [[ ${IS_CRD_CREATED} ]]; then
    echo "CRD ${CRD} has been created in cluster ${CLUSTER_CONTEXT}."
  else
    echo "Timed out! Waited too long for ${CRD} to be created in cluster ${CLUSTER_CONTEXT}."
  fi
}

# Deploy Multi Cluster Ingress configuration.
sed -i "s/RESOURCE_NAME_SUFFIX/${RESOURCE_NAME_SUFFIX}/g" ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml
sed -i "s/PROJECT_ID/${PROJECT_ID}/g" ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml
wait_for_crd "multiclusterservices.networking.gke.io" ${CLUSTER_CONTEXT_CONFIG} "frontend"
wait_for_crd "multiclusteringresses.networking.gke.io" ${CLUSTER_CONTEXT_CONFIG} "frontend"
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  apply -f ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml

# Deploy the redis-cart Service into the US cluster.
# This redis-cart Service gets exported to the other clusters.
wait_for_crd "serviceexports.net.gke.io" ${CLUSTER_CONTEXT_USA} "cartservice"
kubectl --context=${CLUSTER_CONTEXT_USA} \
  apply -f ${K8S_MANIFESTS_DIR}/redis_cart/

# Update the address of the redis-cart used in the Canada cluster.
sed -i "s/redis-cart.cartservice:6379/redis-cart.cartservice.svc.clusterset.local:6379/g" \
  ${K8S_MANIFESTS_DIR}/cartservice/cartservice.yaml
kubectl --context=${CLUSTER_CONTEXT_CANADA} \
  --namespace=cartservice \
  apply -f ${K8S_MANIFESTS_DIR}/cartservice/cartservice.yaml
