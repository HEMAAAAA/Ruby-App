# Accessing Application and Dashboards

This guide explains how to access the Budget App, ArgoCD, and Tekton dashboards after deployment.

## Using NGINX Ingress Controller (Recommended)

The recommended approach is to use the NGINX Ingress Controller with a LoadBalancer service, which provides a single entry point for all services.

### Setting Up Ingress

```bash
# Set up the NGINX Ingress Controller with LoadBalancer
make setup-ingress
```

### Getting the Ingress IP

```bash
make get-ingress-ip
```

This will display the external IP address for the Ingress Controller.

### Configuring Hosts File

Add the following entries to your hosts file (`/etc/hosts` on Linux/Mac or `C:\Windows\System32\drivers\etc\hosts` on Windows):

```
<INGRESS_IP> budgetapp.local argocd.local tekton.local
```

### Accessing the Services

- **Budget Application**: http://budgetapp.local
- **ArgoCD Dashboard**: http://argocd.local
  - Username: admin
  - Password: Get with `kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
- **Tekton Dashboard**: http://tekton.local

## Alternative: Using Port Forwarding

If you prefer not to expose the services externally or are working in a local development environment, you can use port forwarding.

### ArgoCD

```bash
make port-forward-argocd
```

Access ArgoCD at: https://localhost:8080

### Tekton Dashboard

```bash
make port-forward-tekton
```

Access Tekton Dashboard at: http://localhost:9097

### Budget Application

```bash
kubectl port-forward -n budget-app svc/budget-app 3000:80
```

Access the application at: http://localhost:3000

## Alternative: Using Direct LoadBalancer Services

You can also expose each service individually with its own LoadBalancer:

```bash
# Expose ArgoCD server
make expose-argocd

# Expose Tekton dashboard
make expose-tekton
```

Get the external IPs:

```bash
make get-endpoints
```

## Ingress Configuration Details

The Ingress resources are configured to route traffic based on the hostname:

### ArgoCD Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-ingress
  namespace: argocd
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
spec:
  rules:
  - host: argocd.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80
```

### Tekton Dashboard Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tekton-dashboard-ingress
  namespace: tekton-pipelines
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
spec:
  rules:
  - host: tekton.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: tekton-dashboard
            port:
              number: 9097
```

### Budget App Ingress

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: budget-app-ingress
  namespace: budget-app
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
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