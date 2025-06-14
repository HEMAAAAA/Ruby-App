#!/bin/bash

# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready
echo "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

# Apply our custom configurations
echo "Applying ArgoCD configurations..."
kubectl apply -k argocd/

# Update the repository credentials with your actual token
echo "IMPORTANT: Remember to update your GitHub token in repo-credentials.yaml"

# Port forward for easy access (run in background)
echo "Setting up port forwarding to ArgoCD UI on port 8080..."
kubectl port-forward svc/argocd-server -n argocd 8080:443 &

# Get the admin password
echo "ArgoCD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
echo ""

echo "ArgoCD UI is available at: https://localhost:8080"
echo "Username: admin"