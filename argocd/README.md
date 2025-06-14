# ArgoCD Integration for Budget App

This directory contains configuration files for deploying the Budget App using ArgoCD.

## Configuration Files

- **application.yaml**: Defines the application to deploy
- **argocd-cm.yaml**: ArgoCD ConfigMap with custom settings
- **argocd-rbac-cm.yaml**: RBAC configuration for ArgoCD users and roles
- **argocd-notifications-cm.yaml**: Notification templates and triggers
- **repo-credentials.yaml**: Private GitHub repository credentials
- **kustomization.yaml**: Manages all ArgoCD resources

## Installation

1. Update the GitHub token in `repo-credentials.yaml`:
   ```yaml
   password: <your-github-token>  # Replace with your actual GitHub token
   ```

2. Run the setup script:
   ```bash
   ./argocd/setup.sh
   ```

3. Access the ArgoCD UI:
   ```bash
   # Port forwarding (already set up by the script)
   # URL: https://localhost:8080
   # Username: admin
   # Password: (displayed by the setup script)
   ```

## Configuration

- ArgoCD will automatically sync changes from your Git repository to the Kubernetes cluster
- The application is configured to auto-sync and self-heal
- RBAC is configured with admin and readonly roles
- Notifications are set up for deployment success and health degradation