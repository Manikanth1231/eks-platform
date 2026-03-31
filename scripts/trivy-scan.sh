#!/bin/bash
set -e

AWS_ACCOUNT_ID="827472626881"
AWS_REGION="us-east-1"
SERVICES=("user-service" "order-service" "api-gateway")

echo "================================================"
echo "  Trivy Security Scan - $(date)"
echo "================================================"

aws ecr get-login-password --region $AWS_REGION | \
  docker login --username AWS --password-stdin \
  $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

for SERVICE in "${SERVICES[@]}"; do
  IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/dev/$SERVICE:latest"
  echo "Scanning: $SERVICE"
  trivy image --severity HIGH,CRITICAL --exit-code 0 --format table $IMAGE
done

echo "Scanning K8s manifests..."
trivy config --severity HIGH,CRITICAL k8s/

echo "Scanning for secrets..."
trivy fs --scanners secret .

echo "✅ All scans completed"
