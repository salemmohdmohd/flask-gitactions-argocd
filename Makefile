.PHONY: help install run docker-build docker-run k8s-deploy k8s-delete argocd-install argocd-password argocd-ui argocd-deploy clean

help:
	@echo "Available commands:"
	@echo "  make install         - Install Python dependencies"
	@echo "  make run            - Run Flask app locally"
	@echo "  make docker-build   - Build Docker image"
	@echo "  make docker-run     - Run Docker container"
	@echo "  make k8s-deploy     - Deploy to Kubernetes"
	@echo "  make k8s-delete     - Delete from Kubernetes"
	@echo "  make argocd-install - Install ArgoCD"
	@echo "  make argocd-password - Get ArgoCD admin password"
	@echo "  make argocd-ui      - Port-forward ArgoCD UI"
	@echo "  make argocd-deploy  - Deploy app via ArgoCD"
	@echo "  make clean          - Clean up resources"

install:
	pip install -r requirements.txt

run:
	python app.py

docker-build:
	docker build -t cat-flask:local .

docker-run:
	docker run -p 5000:5000 cat-flask:local

k8s-deploy:
	kubectl apply -f k8s/

k8s-delete:
	kubectl delete -f k8s/

k8s-logs:
	kubectl logs -l app=cat-flask -f

k8s-status:
	@echo "=== Pods ==="
	kubectl get pods
	@echo "\n=== Services ==="
	kubectl get svc
	@echo "\n=== Deployments ==="
	kubectl get deploy

argocd-install:
	kubectl create namespace argocd
	kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
	@echo "Waiting for ArgoCD to be ready..."
	kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

argocd-password:
	@kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
	@echo ""

argocd-ui:
	@echo "Access ArgoCD at: https://localhost:8080"
	@echo "Username: admin"
	@echo "Password: Run 'make argocd-password'"
	kubectl port-forward svc/argocd-server -n argocd 8080:443

argocd-deploy:
	kubectl apply -f argocd/application.yaml

argocd-status:
	kubectl get applications -n argocd

clean:
	kubectl delete -f argocd/application.yaml || true
	kubectl delete -f k8s/ || true
	kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml || true
	kubectl delete namespace argocd || true
