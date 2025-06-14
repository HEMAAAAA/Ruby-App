#!/bin/bash

# Install Tekton Pipelines
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# Wait for Tekton Pipelines to be ready
echo "Waiting for Tekton Pipelines to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/tekton-pipelines-controller -n tekton-pipelines

# Install Tekton Triggers
kubectl apply -f https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml

# Wait for Tekton Triggers to be ready
echo "Waiting for Tekton Triggers to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/tekton-triggers-controller -n tekton-pipelines

# Install Tekton Dashboard
kubectl apply -f https://storage.googleapis.com/tekton-releases/dashboard/latest/tekton-dashboard-release.yaml

# Apply our custom resources
kubectl apply -f tekton/install.yaml
kubectl apply -f tekton/rbac.yaml
kubectl apply -f tekton/tasks/
kubectl apply -f tekton/pipeline.yaml
kubectl apply -f tekton/trigger-template.yaml
kubectl apply -f tekton/trigger-binding.yaml
kubectl apply -f tekton/event-listener.yaml

# Set up port forwarding for Tekton Dashboard
echo "Setting up port forwarding to Tekton Dashboard on port 9097..."
kubectl port-forward -n tekton-pipelines svc/tekton-dashboard 9097:9097 &

echo "Tekton CI is installed and configured."
echo "Tekton Dashboard is available at: http://localhost:9097"