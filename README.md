# Cat Facts & Dog API - CI/CD Demo

Flask application demonstrating automated CI/CD pipeline using GitHub Actions and GitOps deployment with ArgoCD to Kubernetes.

## Project Overview

**What This Is:** A production-ready CI/CD demonstration project showing automated deployment from code commit to live Kubernetes application.

**Application:** Flask web app that fetches cat facts and dog images from public APIs.

**CI/CD Pipeline:**

1. **GitHub Actions** builds Docker image on push to `main`
2. Image pushed to **DockerHub**
3. **ArgoCD** detects repo changes and syncs to **Kubernetes**

**What You'll Learn:**

- Containerizing Python applications with Docker
- Automated builds & deployments with GitHub Actions
- GitOps deployment patterns with ArgoCD
- Kubernetes orchestration & management
- Zero-downtime rolling updates
- Infrastructure as Code best practices

**Use Cases:**

- Template for deploying your own Flask/Python apps
- Learning modern CI/CD workflows
- Building production-grade deployment pipelines

**Tech Stack:** Flask, Docker, Kubernetes, GitHub Actions, ArgoCD

## Prerequisites

```bash
# macOS
brew install python@3.11 docker kubectl minikube

# Accounts needed
# - DockerHub: https://hub.docker.com
# - GitHub: https://github.com
```

## Setup Steps

### 1. Configure Files

- Edit `k8s/deployment.yaml`: Replace `YOUR_DOCKERHUB_USERNAME`
- Edit `argocd/application.yaml`: Replace `YOUR_GITHUB_USERNAME`

### 2. DockerHub Setup

- Create repo: https://hub.docker.com/repository/create → Name: `cat-flask` (Public)
- Generate token: https://hub.docker.com/settings/security → New Access Token

### 3. GitHub Secrets

https://github.com/YOUR_USERNAME/flask-gitactions-argocd/settings/secrets/actions

- `DOCKER_USERNAME` = your-dockerhub-username
- `DOCKER_PASSWORD` = your-dockerhub-token

### 4. GitHub Permissions

https://github.com/YOUR_USERNAME/flask-gitactions-argocd/settings/actions
→ Workflow permissions → "Read and write permissions" → Save

### 5. Push & Verify

```bash
git push origin main
```

Watch: https://github.com/YOUR_USERNAME/flask-gitactions-argocd/actions

### 6. Start Kubernetes

```bash
minikube start --cpus=2 --memory=4096
```

### 7. Install ArgoCD

```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
```

### 8. Access ArgoCD

```bash
# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward (Terminal 1)
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

Login: https://localhost:8080 (admin / password-above)

### 9. Deploy App

```bash
kubectl apply -f argocd/application.yaml
kubectl get pods  # Wait for 2 pods
```

### 10. Access App

```bash
# Terminal 2
kubectl port-forward service/cat-flask-service 5000:5000
```

Open: http://localhost:5000

## Test CI/CD

```bash
# Edit templates/index.html
git add . && git commit -m "Test" && git push
```

Watch: GitHub Actions → ArgoCD UI → Pods update → App changes live

## Local Development

```bash
pip install -r requirements.txt && python app.py  # http://localhost:5000
docker build -t cat-flask . && docker run -p 5000:5000 cat-flask
```

## Useful Commands

```bash
kubectl get pods              # Check pods
kubectl logs -l app=cat-flask # View logs
kubectl get applications -n argocd  # ArgoCD status
```

## Cleanup

```bash
kubectl delete -f argocd/application.yaml
kubectl delete -f k8s/
kubectl delete namespace argocd
minikube stop
```

## Troubleshooting

- **Actions fail**: Check secrets at https://github.com/YOUR_USERNAME/flask-gitactions-argocd/settings/secrets/actions
- **ArgoCD not syncing**: Verify repo URL in `argocd/application.yaml`
- **Pods not starting**: `kubectl describe pod -l app=cat-flask`

## Screenshots

### ArgoCD Dashboard
![ArgoCD Application](https://raw.githubusercontent.com/salemmohdmohd/flask-gitactions-argocd/main/docs/Screenshot%202025-10-01%20at%2011.54.23.png)
*ArgoCD showing synced application with healthy status*

### Application UI
![Flask App](https://raw.githubusercontent.com/salemmohdmohd/flask-gitactions-argocd/main/docs/Screenshot%202025-10-01%20at%2011.55.40.png)
*Cat Facts & Dog Images web interface*

### ArgoCD Resource Tree
![ArgoCD Tree](https://raw.githubusercontent.com/salemmohdmohd/flask-gitactions-argocd/main/docs/Screenshot%202025-10-01%20at%2011.55.10.png)
*Kubernetes resources deployed via ArgoCD*

### Deployment Pipeline
![Pipeline](https://raw.githubusercontent.com/salemmohdmohd/flask-gitactions-argocd/main/docs/Screenshot%202025-10-01%20at%2011.56.07.png)
*CI/CD workflow: Git Push → GitHub Actions → DockerHub → ArgoCD → Kubernetes*

## APIs

- Cat Facts: https://catfact.ninja/facts
- Dog Images: https://dog.ceo/api/breeds/image/random
