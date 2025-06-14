.PHONY: setup-gke deploy-tekton deploy-argocd run-pipeline expose-argocd expose-tekton get-endpoints deploy-ingress setup-ingress clean

setup-gke:
	chmod +x setup-gke.sh
	./setup-gke.sh

deploy-tekton:
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
	kubectl apply -f tekton-argocd-integration.yaml

deploy-argocd:
	kubectl apply -f argocd/git-creds-secret.yaml
	kubectl apply -f argocd/dockerhub-creds-secret.yaml
	kubectl apply -f argocd/image-updater-config.yaml
	kubectl apply -f argocd/image-updater-rbac.yaml
	kubectl apply -f argocd/image-updater-deployment.yaml
	kubectl apply -f argocd/application.yaml

setup-ingress:
	chmod +x ingress-setup.sh
	./ingress-setup.sh

deploy-ingress:
	kubectl apply -f argocd/argocd-ingress.yaml
	kubectl apply -f tekton/tekton-ingress.yaml
	@echo "Use 'make get-ingress-ip' to get the LoadBalancer IP"

get-ingress-ip:
	@echo "Ingress LoadBalancer IP:"
	@kubectl get svc -n ingress-nginx ingress-nginx-controller -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
	@echo "\nAdd to your hosts file: <IP> argocd.local tekton.local"

run-pipeline:
	kubectl create -f tekton/pipelinerun.yaml

expose-argocd:
	kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
	@echo "ArgoCD will be available at the external IP (may take a minute to provision):"
	@echo "Run 'make get-endpoints' to see the IP address"

expose-tekton:
	kubectl patch svc tekton-dashboard -n tekton-pipelines -p '{"spec": {"type": "LoadBalancer"}}'
	@echo "Tekton Dashboard will be available at the external IP (may take a minute to provision):"
	@echo "Run 'make get-endpoints' to see the IP address"

get-endpoints:
	@echo "ArgoCD Server:"
	@kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
	@echo " (use https://IP:443)"
	@echo "\nTekton Dashboard:"
	@kubectl get svc tekton-dashboard -n tekton-pipelines -o jsonpath='{.status.loadBalancer.ingress[0].ip}'
	@echo " (use http://IP:9097)"

port-forward-argocd:
	kubectl port-forward svc/argocd-server -n argocd 8080:443

port-forward-tekton:
	kubectl port-forward svc/tekton-dashboard -n tekton-pipelines 9097:9097

clean:
	kubectl delete -f tekton/pipelinerun.yaml --ignore-not-found
	kubectl delete -f argocd/application.yaml --ignore-not-found
	kubectl delete -f tekton/tekton-trigger.yaml --ignore-not-found
	kubectl delete -f tekton/pipeline.yaml --ignore-not-found