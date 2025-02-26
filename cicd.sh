#!/bin/bash
set -e

# Define image name and app name
IMAGE="joelwembo/argocd_blue_green_demo:latest"
APP_NAME="argocd-blue-green-demo"

echo "Building Docker image..."
docker build -t ${IMAGE} .

echo "Pushing Docker image..."
docker push ${IMAGE}

# Optional: Run the container for testing (simulate blue/green validation)
echo "Running Docker container for testing..."
CONTAINER_NAME="argocd_demo_test"
docker run --rm -d --name ${CONTAINER_NAME} -p 5000:5000 ${IMAGE}

echo "Waiting for the container to initialize..."
sleep 10

echo "Testing the application..."
curl -s http://localhost:5000 || { echo "Application did not respond as expected"; exit 1; }

echo "Stopping test container..."
docker stop ${CONTAINER_NAME}

# Push code changes to GitHub
echo "Pushing code changes to GitHub..."
git add .
git commit -m "Blue Green Deployment: Update application"
git push origin master

# Sync the ArgoCD application
echo "Syncing ArgoCD application..."
argocd app sync ${APP_NAME}

echo "CI/CD pipeline completed successfully."
