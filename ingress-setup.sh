#!/bin/bash
set -e

# Install NGINX Ingress Controller
echo "Installing NGINX Ingress Controller with LoadBalancer..."
kubectl apply -f nginx-ingress-controller.yaml

# Wait for the Ingress Controller to be ready
echo "Waiting for Ingress Controller to be ready..."
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=120s

# Deploy Ingress resources
echo "Deploying Ingress resources..."
kubectl apply -f argocd/argocd-ingress.yaml
kubectl apply -f tekton/tekton-ingress.yaml

# Get the LoadBalancer IP
echo "Getting LoadBalancer IP..."
INGRESS_IP=""
while [ -z "$INGRESS_IP" ]; do
  INGRESS_IP=$(kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  if [ -z "$INGRESS_IP" ]; then
    echo "Waiting for LoadBalancer IP..."
    sleep 5
  fi
done

echo ""
echo "NGINX Ingress Controller is available at: $INGRESS_IP"
echo ""
echo "Add the following entries to your hosts file:"
echo "$INGRESS_IP argocd.local tekton.local"
echo ""
echo "Then access the services at:"
echo "ArgoCD: http://argocd.local"
echo "Tekton Dashboard: http://tekton.local"