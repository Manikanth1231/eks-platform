#!/bin/bash
set -e

echo "================================================"
echo "  WARNING: This will delete all resources!"
echo "================================================"
read -p "Are you sure? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
  echo "Cancelled."
  exit 0
fi

kubectl delete namespace microservices 2>/dev/null || true
kubectl delete namespace monitoring    2>/dev/null || true
kubectl delete namespace logging       2>/dev/null || true
kubectl delete namespace argocd        2>/dev/null || true
kubectl delete namespace vault         2>/dev/null || true
echo "✅ Kubernetes resources deleted"

cd terraform
terraform destroy -var-file=envs/dev.tfvars -auto-approve
echo "✅ Terraform resources destroyed"
