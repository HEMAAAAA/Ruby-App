# Architecture Overview

This document describes the architecture of the Ruby Budget App deployment on Google Kubernetes Engine (GKE).

## Components

### 1. Application
- Ruby on Rails application
- PostgreSQL database
- Containerized with Docker

### 2. CI/CD Pipeline
- **Tekton Pipelines**: Handles continuous integration and delivery
  - Clones the repository
  - Builds and tests the application
  - Creates Docker images with version tags
  - Updates Kubernetes manifests
  - Commits changes back to Git

### 3. GitOps Deployment
- **ArgoCD**: Manages deployments using GitOps principles
  - Monitors Git repository for changes
  - Synchronizes Kubernetes cluster state with Git
  - Provides visualization and management UI

### 4. Automated Updates
- **ArgoCD Image Updater**: Automates image version updates
  - Monitors Docker registry for new image versions
  - Updates Kustomize configuration with new image tags
  - Commits changes back to Git

### 5. Infrastructure
- **Google Kubernetes Engine**: Managed Kubernetes service
  - Provides scalable container orchestration
  - Integrates with Google Cloud services

### 6. Ingress Management
- **NGINX Ingress Controller**: Manages external access
  - Routes traffic based on hostnames
  - Provides a single entry point for multiple services
  - Uses LoadBalancer for external access

## End-to-End Workflow

1. **Code Commit**: Developer commits code to GitHub repository
2. **Automated Trigger**: GitHub webhook triggers Tekton pipeline via EventListener
3. **Build Phase**:
   - Tekton clones the repository
   - Builds the application
   - Runs tests to ensure quality
4. **Image Creation**:
   - Tekton builds a Docker image with a unique tag
   - Pushes the image to Docker Hub
5. **Manifest Update**:
   - Tekton updates Kubernetes manifests with the new image tag
   - Commits and pushes changes back to the Git repository
6. **Deployment**:
   - ArgoCD detects changes in the Git repository
   - Synchronizes the application state with the cluster
   - Deploys the updated application
7. **Continuous Updates**:
   - ArgoCD Image Updater monitors Docker Hub for new image versions
   - Updates the Kustomize configuration when new images are available
   - Triggers ArgoCD to deploy the updated image
8. **Access**:
   - NGINX Ingress Controller routes external traffic to services
   - Users access the application via the configured hostname

## Architecture Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│   GitHub    │────▶│   Tekton    │
└─────────────┘     └─────────────┘     │   Pipeline  │
                                        └─────────────┘
                                              │
                                              ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  ArgoCD     │◀────│  Git Repo   │◀────│  Docker     │
│  Deployment │     │  (Updated)  │     │  Registry   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                                       ▲
      │                                       │
      ▼                                       │
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  GKE        │◀────│  Ingress    │     │  Image      │
│  Cluster    │     │  Controller │     │  Updater    │
└─────────────┘     └─────────────┘     └─────────────┘
      │                    ▲
      │                    │
      ▼                    │
┌─────────────┐     ┌─────────────┐
│ Application │     │   Users     │
│ Dashboards  │◀────│   Browser   │
└─────────────┘     └─────────────┘
```

## Component Interaction

### Tekton and ArgoCD Integration

Tekton and ArgoCD are integrated through:
1. **Git Repository**: Tekton updates manifests, ArgoCD detects changes
2. **Direct Sync**: Tekton can trigger ArgoCD sync after pipeline completion
3. **Shared Workspace**: Both systems operate on the same Kubernetes cluster

### Image Management

The image update process flows through:
1. **Tekton**: Builds and pushes images with unique tags
2. **Git Repository**: Stores updated image references in Kustomize files
3. **ArgoCD Image Updater**: Monitors for new images and updates references
4. **ArgoCD**: Deploys the updated images

### Ingress Traffic Flow

External traffic flows through:
1. **LoadBalancer**: Provides external IP for the Ingress Controller
2. **NGINX Ingress Controller**: Routes traffic based on hostnames
3. **Kubernetes Services**: Direct traffic to appropriate pods
4. **Application Pods**: Process requests and return responses