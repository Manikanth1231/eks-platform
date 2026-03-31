#!/bin/bash
set -e

echo "================================================"
echo "  EKS Platform Health Check - $(date)"
echo "================================================"

FAILED=0

echo "1. Checking nodes..."
NODES=$(kubectl get nodes --no-headers | grep -v Ready | wc -l)
if [ "$NODES" -eq 0 ]; then
  echo "✅ All nodes are Ready"
else
  echo "❌ $NODES nodes are not Ready"
  FAILED=1
fi

echo "2. Checking microservices..."
FAILED_PODS=$(kubectl get pods -n microservices --no-headers | grep -v Running | wc -l)
if [ "$FAILED_PODS" -eq 0 ]; then
  echo "✅ All microservices are Running"
else
  echo "❌ $FAILED_PODS pods are not Running"
  kubectl get pods -n microservices
  FAILED=1
fi

echo "3. Checking monitoring..."
FAILED_MON=$(kubectl get pods -n monitoring --no-headers | grep -v Running | wc -l)
if [ "$FAILED_MON" -eq 0 ]; then
  echo "✅ Monitoring stack is Running"
else
  echo "❌ $FAILED_MON monitoring pods not Running"
  FAILED=1
fi

echo "4. Checking ArgoCD..."
FAILED_ARGO=$(kubectl get pods -n argocd --no-headers | grep -v Running | wc -l)
if [ "$FAILED_ARGO" -eq 0 ]; then
  echo "✅ ArgoCD is Running"
else
  echo "⚠️  $FAILED_ARGO ArgoCD pods not Running"
fi

echo "5. Checking API endpoint..."
LB_URL=$(kubectl get svc api-gateway -n microservices \
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://$LB_URL/health)
if [ "$HTTP_CODE" -eq 200 ]; then
  echo "✅ API endpoint is healthy (HTTP $HTTP_CODE)"
else
  echo "❌ API endpoint returned HTTP $HTTP_CODE"
  FAILED=1
fi

echo ""
echo "================================================"
if [ "$FAILED" -eq 0 ]; then
  echo "✅ All health checks passed!"
else
  echo "❌ Some health checks failed!"
fi
echo "================================================"
exit $FAILED
