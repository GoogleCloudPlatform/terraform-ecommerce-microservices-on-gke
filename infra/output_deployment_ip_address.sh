# Script parameters
PROJECT_ID=$1
RESOURCE_NAME_SUFFIX=$2

CLUSTER_CONTEXT_CONFIG=gke_${PROJECT_ID}_us-west1_my-cluster-config${RESOURCE_NAME_SUFFIX}

echo 'Waiting for MultiClusterIngress IP address...'
DEPLOYMENT_IP_ADDRESS=''
while [[ -z ${DEPLOYMENT_IP_ADDRESS} ]]
do
  DEPLOYMENT_IP_ADDRESS=$(kubectl \
    --context=${CLUSTER_CONTEXT_CONFIG} \
    --namespace frontend \
    get MultiClusterIngress frontend-multi-cluster-ingress \
    --output jsonpath='{.status.VIP}')
  sleep 0.05s # To avoid spamming.
done

echo "Creating file deployment_ip_address containing IP address: ${DEPLOYMENT_IP_ADDRESS}"
echo ${DEPLOYMENT_IP_ADDRESS} > deployment_ip_address
