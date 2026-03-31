#!/bin/bash
set -e

CLUSTER_NAME="eks-platform-dev"
REGION="us-east-1"

echo "================================================"
echo "  EKS Platform Bootstrap Script"
echo "================================================"

echo "1. Configuring kubectl..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
echo "✅ kubectl configured"

echo "2. Verifying cluster..."
kubectl get nodes
echo "✅ Cluster verified"

echo "3. Creating namespaces..."
kubectl create namespace microservices 2>/dev/null || echo "namespace exists"
kubectl create namespace monitoring    2>/dev/null || echo "namespace exists"
kubectl create namespace logging       2>/dev/null || echo "namespace exists"
kubectl create namespace argocd        2>/dev/null || echo "namespace exists"
kubectl create namespace vault         2>/dev/null || echo "namespace exists"
echo "✅ Namespaces created"

echo "4. Deploying microservices..."
kubectl apply -f k8s/apps/user-service/
kubectl apply -f k8s/apps/order-service/
kubectl apply -f k8s/apps/api-gateway/
echo "✅ Microservices deployed"

echo ""
echo "================================================"
echo "  Access Information"
echo "================================================"
echo "App URL: $(kubectl get svc api-gateway -n microservices \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')"
echo "================================================"
