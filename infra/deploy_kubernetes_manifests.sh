# Script parameters
PROJECT_ID=$1
RESOURCE_NAME_SUFFIX=$2

CLUSTER_CONTEXT_CANADA=gke_${PROJECT_ID}_northamerica-northeast1_my-cluster-canada${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_CONFIG=gke_${PROJECT_ID}_us-west1_my-cluster-config${RESOURCE_NAME_SUFFIX}
CLUSTER_CONTEXT_USA=gke_${PROJECT_ID}_us-west1_my-cluster-usa${RESOURCE_NAME_SUFFIX}
K8S_MANIFESTS_DIR=../kubernetes_manifests

# Connect to the 3 clusters that we just created.
gcloud container clusters get-credentials my-cluster-canada${RESOURCE_NAME_SUFFIX} \
  --project ${PROJECT_ID} \
  --region northamerica-northeast1
gcloud container clusters get-credentials my-cluster-usa${RESOURCE_NAME_SUFFIX} \
  --project ${PROJECT_ID} \
  --region us-west1
gcloud container clusters get-credentials my-cluster-config${RESOURCE_NAME_SUFFIX} \
  --project ${PROJECT_ID} \
  --region us-west1

app_namespaces=(adservice cartservice checkoutservice currencyservice emailservice frontend paymentservice productcatalogservice recommendationservice shippingservice)

# Create namespaces.
# Some Namespaces (especially in my-cluster-config) will be unused.
kubectl --context=${CLUSTER_CONTEXT_USA} \
  apply -f ${K8S_MANIFESTS_DIR}/namespaces.yaml
kubectl --context=${CLUSTER_CONTEXT_CANADA} \
  apply -f ${K8S_MANIFESTS_DIR}/namespaces.yaml
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  apply -f ${K8S_MANIFESTS_DIR}/namespaces.yaml

# Deploy most of Cymbal Shops.
for namespace in "${app_namespaces[@]}";
do
  kubectl --context=${CLUSTER_CONTEXT_USA} \
    apply -f ${K8S_MANIFESTS_DIR}/${namespace}/
  kubectl --context=${CLUSTER_CONTEXT_CANADA} \
    apply -f ${K8S_MANIFESTS_DIR}/${namespace}/
done

# Deploy Multi Cluster Ingress configuration.
kubectl --context=${CLUSTER_CONTEXT_CONFIG} \
  apply -f ${K8S_MANIFESTS_DIR}/multi_cluster_ingress.yaml

# Deploy the redis-cart Service into the US cluster.
# This redis-cart Service gets exported to the other clusters.
kubectl --context=${CLUSTER_CONTEXT_USA} \
  apply -f ${K8S_MANIFESTS_DIR}/redis_cart/
