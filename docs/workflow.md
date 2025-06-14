# End-to-End Workflow: From Code Commit to Deployment

This document explains the complete workflow from code commit to deployment in the Ruby Budget App CI/CD pipeline.

## Overview

The CI/CD pipeline integrates Tekton, ArgoCD, and Kubernetes to provide a seamless workflow from code changes to production deployment. The workflow is fully automated and follows GitOps principles.

## Step-by-Step Workflow

### 1. Code Commit

The workflow begins when a developer commits code to the GitHub repository:

```bash
git add .
git commit -m "Feature: Add new budget tracking functionality"
git push origin main
```

### 2. Webhook Trigger

A GitHub webhook triggers the Tekton EventListener, which starts the CI pipeline:

- The webhook sends a POST request to the Tekton EventListener
- The EventListener creates a PipelineRun resource
- Tekton starts executing the pipeline tasks

### 3. CI Pipeline (Tekton)

The Tekton pipeline performs the following tasks:

#### a. Clone Repository
```yaml
- name: clone-repo
  taskRef:
    name: git-clone
    kind: ClusterTask
  workspaces:
    - name: output
      workspace: shared-workspace
  params:
    - name: url
      value: https://github.com/HEMAAAAA/Ruby-App.git
    - name: revision
      value: main
```

#### b. Build and Test Application
- Runs tests to ensure code quality
- Prepares the application for containerization

#### c. Build and Push Docker Image
```yaml
- name: build-and-push
  taskRef:
    name: buildah
    kind: ClusterTask
  params:
    - name: IMAGE
      value: docker.io/hema995/budgetapp:$(params.IMAGE_TAG)
```

#### d. Update Kubernetes Manifests
```yaml
- name: update-manifests
  taskRef:
    name: update-k8s-manifests
  params:
    - name: image-name
      value: docker.io/hema995/budgetapp
    - name: image-tag
      value: $(params.IMAGE_TAG)
```

#### e. Commit Changes Back to Git
```yaml
- name: git-commit
  taskRef:
    name: git-commit-push
  params:
    - name: message
      value: "Update image tag to $(params.IMAGE_TAG)"
```

### 4. CD Pipeline (ArgoCD)

ArgoCD handles the deployment process:

#### a. Detect Git Changes
- ArgoCD continuously monitors the Git repository
- Detects changes to Kubernetes manifests

#### b. Synchronize Application State
```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: budget-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/HEMAAAAA/Ruby-App.git
    targetRevision: HEAD
    path: kubernetes
  destination:
    server: https://kubernetes.default.svc
    namespace: budget-app
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

#### c. Deploy Updated Application
- ArgoCD applies the updated manifests to the cluster
- Ensures the desired state matches the actual state

### 5. Continuous Image Updates (ArgoCD Image Updater)

ArgoCD Image Updater automates image version updates:

```yaml
metadata:
  annotations:
    argocd-image-updater.argoproj.io/image-list: docker.io/hema995/budgetapp
    argocd-image-updater.argoproj.io/docker.io/hema995/budgetapp.update-strategy: semver
```

- Monitors Docker Hub for new image versions
- Updates Kustomize configuration with new image tags
- Triggers ArgoCD to deploy the updated image

### 6. External Access (NGINX Ingress)

The NGINX Ingress Controller provides external access to the application and dashboards:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: budget-app-ingress
  namespace: budget-app
spec:
  rules:
  - host: budgetapp.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: budget-app
            port:
              number: 80
```

## Workflow Diagram

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Developer  │────▶│   GitHub    │────▶│   Webhook   │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Update     │◀────│   Build     │◀────│   Tekton    │
│  Manifests  │     │   Image     │     │   Pipeline  │
└─────────────┘     └─────────────┘     └─────────────┘
      │                                       
      ▼                                       
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Git        │────▶│   ArgoCD    │────▶│   Deploy    │
│  Commit     │     │   Sync      │     │   to K8s    │
└─────────────┘     └─────────────┘     └─────────────┘
                                              │
                                              ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  Image      │────▶│   Update    │────▶│   Access    │
│  Updater    │     │   Image     │     │   via       │
└─────────────┘     └─────────────┘     │   Ingress   │
                                        └─────────────┘
```

## Troubleshooting

If any part of the workflow fails:

1. **Tekton Pipeline Failures**:
   - Check the PipelineRun status: `kubectl get pipelinerun`
   - View task logs: `tkn pipelinerun logs <pipelinerun-name>`

2. **ArgoCD Sync Issues**:
   - Check the Application status in ArgoCD UI
   - View sync logs: `kubectl logs -n argocd deployment/argocd-application-controller`

3. **Image Updater Problems**:
   - Check logs: `kubectl logs -n argocd deployment/argocd-image-updater`
   - Verify Docker Hub credentials

4. **Ingress Access Issues**:
   - Check Ingress status: `kubectl get ingress -A`
   - Verify LoadBalancer IP: `kubectl get svc -n ingress-nginx`