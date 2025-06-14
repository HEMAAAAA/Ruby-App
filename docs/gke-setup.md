# GKE Setup Guide

This guide provides detailed instructions for setting up the Ruby Budget App on Google Kubernetes Engine (GKE).

## Prerequisites

1. Google Cloud SDK installed and configured
2. `kubectl` installed
3. Docker installed
4. Access to GitHub repository
5. Docker Hub account

## Step 1: Create GKE Cluster

```bash
gcloud container clusters create budget-app-cluster \
  --num-nodes=2 \
  --machine-type=e2-standard-2 \
  --zone=us-central1-a
```

Configure kubectl to use the cluster:

```bash
gcloud container clusters get-credentials budget-app-cluster --zone=us-central1-a
```

## Step 2: Install Tekton

Install Tekton Pipelines:

```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml
```

Install Tekton Triggers:

```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
```

Install Tekton Dashboard:

```bash
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml
```

## Step 3: Install ArgoCD

Create namespace:

```bash
kubectl create namespace argocd
```

Install ArgoCD:

```bash
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

## Step 4: Configure Secrets

Update the following files with your credentials:

- `argocd/git-creds-secret.yaml`: GitHub credentials
- `argocd/dockerhub-creds-secret.yaml`: Docker Hub credentials
- `tekton/github-secret.yaml`: GitHub credentials for Tekton

Apply the secrets:

```bash
kubectl apply -f argocd/git-creds-secret.yaml
kubectl apply -f argocd/dockerhub-creds-secret.yaml
kubectl apply -f tekton/github-secret.yaml
```

## Step 5: Deploy Tekton Resources

```bash
kubectl apply -f tekton/workspace-pvc.yaml
kubectl apply -f tekton/service-account.yaml
kubectl apply -f tekton/git-resource.yaml
kubectl apply -f tekton/docker-resource.yaml
kubectl apply -f tekton/kustomize-task.yaml
kubectl apply -f tekton/git-commit-task.yaml
kubectl apply -f tekton/update-k8s-task.yaml
kubectl apply -f tekton/pipeline.yaml
kubectl apply -f tekton/tekton-trigger.yaml
kubectl apply -f tekton-argocd-integration.yaml
```

## Step 6: Deploy ArgoCD Resources

```bash
kubectl apply -f argocd/image-updater-config.yaml
kubectl apply -f argocd/image-updater-rbac.yaml
kubectl apply -f argocd/image-updater-deployment.yaml
kubectl apply -f argocd/application.yaml
```

## Step 7: Access ArgoCD UI

Port forward to access the ArgoCD UI:

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Access the UI at https://localhost:8080

Default username: admin
Get the password:

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## Step 8: Access Tekton Dashboard

Port forward to access the Tekton Dashboard:

```bash
kubectl port-forward svc/tekton-dashboard -n tekton-pipelines 9097:9097
```

Access the dashboard at http://localhost:9097