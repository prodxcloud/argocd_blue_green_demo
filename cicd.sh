#!/bin/bash
set -e

# Variables
IMAGE="joelwembo/argocd_blue_green_demo:latest"
NAMESPACE="argocd"
GREEN_DEPLOYMENT="argocd-blue-green-demo-green"
BLUE_DEPLOYMENT="argocd-blue-green-demo-blue"
SERVICE_NAME="argocd-blue-green-demo-service"

echo "Building Docker image..."
docker build -t ${IMAGE} .

echo "Pushing Docker image..."
docker push ${IMAGE}

# Ensure Green deployment exists; if not, create it from Blue
if ! kubectl get deployment ${GREEN_DEPLOYMENT} -n ${NAMESPACE} >/dev/null 2>&1; then
    echo "Green deployment not found. Creating it from Blue deployment..."
    kubectl get deployment ${BLUE_DEPLOYMENT} -n ${NAMESPACE} -o yaml \
      | sed "s/name: ${BLUE_DEPLOYMENT}/name: ${GREEN_DEPLOYMENT}/" \
      | sed "s/version: blue/version: green/g" \
      | kubectl apply -n ${NAMESPACE} -f -
fi

echo "Updating Green Deployment with new image..."
kubectl -n ${NAMESPACE} set image deployment/${GREEN_DEPLOYMENT} argocd-blue-green-demo=${IMAGE}

echo "Scaling up Green Deployment..."
kubectl -n ${NAMESPACE} scale deployment ${GREEN_DEPLOYMENT} --replicas=1

echo "Waiting for Green Deployment rollout..."
kubectl -n ${NAMESPACE} rollout status deployment/${GREEN_DEPLOYMENT}

# Optional: Validate the new version by port-forwarding the green deployment for testing
echo "Port-forwarding Green Deployment for testing on port 5001..."
kubectl -n ${NAMESPACE} port-forward deployment/${GREEN_DEPLOYMENT} 5001:5000 &
PF_PID=$!
sleep 10

echo "Testing the Green Deployment..."
if curl -s http://localhost:5001 > /dev/null; then
    echo "Green Deployment test succeeded."
else
    echo "Green Deployment test failed!"
    kill ${PF_PID}
    exit 1
fi

# Clean up port-forward
kill ${PF_PID}

echo "Switching Service to direct traffic to Green Deployment..."
kubectl -n ${NAMESPACE} patch svc ${SERVICE_NAME} -p '{"spec": {"selector": {"app": "argocd-blue-green-demo", "version": "green"}}}'

echo "Scaling down Blue Deployment..."
kubectl -n ${NAMESPACE} scale deployment ${BLUE_DEPLOYMENT} --replicas=0

echo "Blue-green deployment completed successfully."
