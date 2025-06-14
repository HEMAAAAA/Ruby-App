
# Ruby Budget App - GKE Deployment

A Ruby on Rails budget application with CI/CD pipeline for Google Kubernetes Engine using Tekton and ArgoCD.

## Architecture

- **Tekton Pipelines**: CI automation
- **ArgoCD**: GitOps-based CD
- **ArgoCD Image Updater**: Automatic image updates
- **NGINX Ingress**: External access

## Prerequisites

- Google Cloud account with GKE cluster
- `kubectl` configured for your GKE cluster
- Docker Hub account
- GitHub account with personal access token

## Quick Start

```bash
# Clone the repository
git clone https://github.com/HEMAAAAA/Ruby-App.git
cd Ruby-App

# Create GKE cluster
gcloud container clusters create budget-app-cluster \
  --num-nodes=2 \
  --machine-type=e2-standard-2 \
  --zone=us-central1-a

# Get credentials
gcloud container clusters get-credentials budget-app-cluster --zone=us-central1-a

# Setup CI/CD and deploy
./setup-gke.sh

# Setup Ingress
./ingress-setup.sh
```

## End-to-End Workflow

1. **Code Commit**: Push code to GitHub
2. **CI Pipeline** (Tekton):
   - Builds and tests application
   - Creates Docker image with unique tag
   - Updates Kubernetes manifests
   - Commits changes back to Git
3. **CD Pipeline** (ArgoCD):
   - Detects Git changes
   - Deploys to Kubernetes
4. **Image Updates** (ArgoCD Image Updater):
   - Monitors for new images
   - Updates manifests automatically

After deployment, get the Ingress IP:

```bash
kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
```

Add to your hosts file:
```
<INGRESS_IP> budgetapp.local argocd.local tekton.local
```

Access services:
- Application: http://budgetapp.local
- ArgoCD: http://argocd.local (admin / get password with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`)
- Tekton: http://tekton.local

## Directory Structure

- `/kubernetes`: Kubernetes manifests
- `/tekton`: Tekton pipeline configurations
- `/argocd`: ArgoCD configurations
