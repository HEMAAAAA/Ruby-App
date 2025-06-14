# Ruby Budget App - GKE Deployment

This repository contains a Ruby on Rails budget application with a complete CI/CD pipeline for deployment to Google Kubernetes Engine (GKE).

## Architecture

The deployment architecture consists of:

- **Tekton Pipelines**: For CI/CD automation
- **ArgoCD**: For GitOps-based deployment
- **ArgoCD Image Updater**: For automatic image updates
- **Kubernetes**: For container orchestration on GKE
- **NGINX Ingress**: For routing external traffic

For a detailed architecture overview, see [Architecture Documentation](docs/architecture.md).

## Quick Start

```bash
# Clone the repository
git clone https://github.com/HEMAAAAA/Ruby-App.git
cd Ruby-App

# Set up GKE and deploy the application
make setup-gke

# Set up Ingress for accessing dashboards and application
make setup-ingress
```

## Prerequisites

- Google Cloud account with GKE cluster
- `kubectl` configured to access your GKE cluster
- Docker Hub account
- GitHub account with personal access token

## Setup Options

### Option 1: Automated Setup

Use the provided setup script:

```bash
chmod +x setup-gke.sh
./setup-gke.sh
chmod +x ingress-setup.sh
./ingress-setup.sh
```

### Option 2: Manual Setup

Follow the step-by-step instructions in the [GKE Setup Guide](docs/gke-setup.md).

### Option 3: Using Make

```bash
# Set up the entire infrastructure
make setup-gke

# Deploy only Tekton components
make deploy-tekton

# Deploy only ArgoCD components
make deploy-argocd

# Set up Ingress Controller with LoadBalancer
make setup-ingress

# Get Ingress LoadBalancer IP
make get-ingress-ip

# Run the pipeline manually
make run-pipeline
```

## End-to-End Workflow

1. **Code Commit**: Developer commits code to GitHub repository
2. **Automated Trigger**: GitHub webhook triggers Tekton pipeline
3. **CI Pipeline** (Tekton): 
   - Clones the repository
   - Builds and tests the application
   - Creates a Docker image with a new tag
   - Pushes the image to Docker Hub
   - Updates Kubernetes manifests with the new image tag
   - Commits changes back to the repository
4. **CD Pipeline** (ArgoCD): 
   - Detects changes in the Git repository
   - Synchronizes the application state with the cluster
   - Deploys the updated application
5. **Continuous Updates** (ArgoCD Image Updater):
   - Monitors Docker Hub for new image versions
   - Updates the Kustomize configuration when new images are available
   - Triggers ArgoCD to deploy the updated image

## Accessing Services

All services are accessible through a single Ingress LoadBalancer IP:

```bash
# Get the Ingress IP
make get-ingress-ip
```

Then add to your hosts file:
```
<INGRESS_IP> budgetapp.local argocd.local tekton.local
```

- **Application**: http://budgetapp.local
- **ArgoCD Dashboard**: http://argocd.local
  - Username: admin
  - Password: Get with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- **Tekton Dashboard**: http://tekton.local

For more details, see [Accessing UI Guide](docs/accessing-ui.md).

## Folder Structure

- `/kubernetes`: Kubernetes manifests
- `/tekton`: Tekton pipeline configurations
- `/argocd`: ArgoCD configurations
- `/docs`: Documentation files

## Contributing

1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.