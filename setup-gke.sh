#!/bin/bash
set -e
# Install Tekton
echo "Installing Tekton..."
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

# Install ArgoCD
echo "Installing ArgoCD..."
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Apply Tekton resources
echo "Applying Tekton resources..."
kubectl apply -f tekton/workspace-pvc.yaml
kubectl apply -f tekton/github-secret.yaml
kubectl apply -f tekton/service-account.yaml
kubectl apply -f tekton/git-resource.yaml
kubectl apply -f tekton/docker-resource.yaml
kubectl apply -f tekton/kustomize-task.yaml
kubectl apply -f tekton/git-commit-task.yaml
kubectl apply -f tekton/update-k8s-task.yaml
kubectl apply -f tekton/pipeline.yaml
kubectl apply -f tekton/tekton-trigger.yaml
kubectl apply -f tekton/tekton-dashboard-loadbalancer.yaml

# Apply ArgoCD resources
echo "Applying ArgoCD resources..."
kubectl apply -f argocd/git-creds-secret.yaml
kubectl apply -f argocd/dockerhub-creds-secret.yaml
kubectl apply -f argocd/image-updater-config.yaml
kubectl apply -f argocd/image-updater-rbac.yaml
kubectl apply -f argocd/image-updater-deployment.yaml
kubectl apply -f argocd/application.yaml
kubectl apply -f argocd/argocd-loadbalancer.yaml

echo "Setup complete!"
echo "Default ArgoCD username: admin"
echo "Get ArgoCD password with: kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d"
echo ""
echo "Waiting for LoadBalancer IP addresses to be assigned..."
echo "This may take a minute or two..."
echo ""

# Wait for LoadBalancer IPs to be assigned
for i in {1..30}; do
  ARGOCD_IP=$(kubectl get svc argocd-server-lb -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  TEKTON_IP=$(kubectl get svc tekton-dashboard-lb -n tekton-pipelines -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
  
  if [[ -n "$ARGOCD_IP" && -n "$TEKTON_IP" ]]; then
    break
  fi
  echo -n "."
  sleep 5
done
echo ""

echo "Access ArgoCD UI at: https://$ARGOCD_IP"
echo "Access Tekton Dashboard at: http://$TEKTON_IP"