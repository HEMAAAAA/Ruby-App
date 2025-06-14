# Tekton CI for Budget App

This directory contains configuration files for setting up Continuous Integration with Tekton Pipelines.

## Installation

1. Install Tekton and all required components:

```bash
./tekton/setup.sh
```

2. Access the Tekton Dashboard:

```bash
# The setup script already sets up port forwarding
# Dashboard will be available at http://localhost:9097
```

## Configuration

1. Update the Git repository URL in:
   - `tekton/pipelinerun.yaml`
   - Configure your Git repository to send webhook events to the EventListener

2. Set up Docker credentials for pushing images:

```bash
kubectl create secret docker-registry docker-credentials \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=<your-username> \
  --docker-password=<your-password> \
  --docker-email=<your-email> \
  -n tekton-pipelines
```

3. Expose the EventListener service to receive webhooks:

```bash
kubectl expose service el-budget-app-event-listener --type=LoadBalancer --name=el-budget-app-public -n tekton-pipelines
```

## Pipeline Structure

1. **fetch-source**: Clones the Git repository
2. **run-tests**: Runs Ruby tests
3. **build-image**: Builds and pushes the Docker image
4. **update-manifest**: Updates the Kubernetes deployment manifest with the new image tag

## Manual Execution

To manually trigger the pipeline:

```bash
kubectl apply -f tekton/pipelinerun.yaml
```