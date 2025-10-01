# Cat Facts & Dog API - CI/CD Demo

Flask application demonstrating automated CI/CD pipeline using GitHub Actions and GitOps deployment with ArgoCD to Kubernetes.

## Project Overview

**Application:** Flask web app that fetches cat facts and dog images from public APIs.

**CI/CD Pipeline:**
1. **GitHub Actions** builds Docker image on push to `main`
2. Image pushed to **DockerHub**
3. **ArgoCD** detects repo changes and syncs to **Kubernetes**

**Tech Stack:** Flask, Docker, Kubernetes, GitHub Actions, ArgoCD

## Prerequisites

- Python 3.11+
- Docker
- Kubernetes cluster (Minikube/Kind/Cloud)
- kubectl
- ArgoCD installed on cluster
- DockerHub account
- GitHub account

## Quick Start

### 1. Local Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run app
python app.py

# Visit http://localhost:5000
```

### 2. Docker

```bash
# Build image
docker build -t cat-flask .

# Run container
docker run -p 5000:5000 cat-flask

# Visit http://localhost:5000
```

### 3. Kubernetes (Minikube)

```bash
# Start Minikube
minikube start

# Apply manifests
kubectl apply -f k8s/

# Access service
minikube service cat-flask-service

# Or port-forward
kubectl port-forward service/cat-flask-service 5000:5000
```

## Setup Instructions

### Step 1: Clone Repository

```bash
git clone https://github.com/YOUR_USERNAME/flask-gitactions-argocd.git
cd flask-gitactions-argocd
```

### Step 2: Configure GitHub Secrets

Add secrets in GitHub repo: Settings → Secrets and variables → Actions

- `DOCKER_USERNAME`: Your DockerHub username
- `DOCKER_PASSWORD`: Your DockerHub password/token

### Step 3: Update Configuration

**In `k8s/deployment.yaml`:**
- Replace `YOUR_DOCKERHUB_USERNAME` with your DockerHub username

**In `argocd/application.yaml`:**
- Replace `YOUR_GITHUB_USERNAME` with your GitHub username

### Step 4: Install ArgoCD on Kubernetes

```bash
# Create namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for pods
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port-forward ArgoCD UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Login: https://localhost:8080
# Username: admin
# Password: (from above command)
```

### Step 5: Deploy Application with ArgoCD

```bash
# Apply ArgoCD application
kubectl apply -f argocd/application.yaml

# Check status
kubectl get applications -n argocd

# Access app
kubectl port-forward service/cat-flask-service 5000:5000
```

### Step 6: Push to GitHub

```bash
git add .
git commit -m "Initial commit"
git push origin main
```

GitHub Actions will automatically:
- Build Docker image
- Push to DockerHub
- Update deployment manifest

ArgoCD will automatically:
- Detect changes
- Sync to Kubernetes cluster

## How It Works

### CI Pipeline (GitHub Actions)

1. Code pushed to `main` branch
2. GitHub Actions workflow triggers
3. Builds Docker image
4. Pushes image to DockerHub
5. Updates `k8s/deployment.yaml` with new image tag
6. Commits changes back to repo

### CD Pipeline (ArgoCD)

1. ArgoCD monitors GitHub repo every 3 minutes
2. Detects changes in `k8s/` directory
3. Automatically syncs manifests to Kubernetes
4. Self-heals if manual changes made
5. Prunes deleted resources

## Project Structure

```
flask-gitactions-argocd/
├── app.py                      # Flask application
├── requirements.txt            # Python dependencies
├── Dockerfile                  # Container image definition
├── templates/
│   └── index.html             # HTML template
├── k8s/
│   ├── deployment.yaml        # Kubernetes deployment
│   ├── service.yaml           # Kubernetes service
│   └── ingress.yaml           # Ingress resource (optional)
├── argocd/
│   └── application.yaml       # ArgoCD application manifest
└── .github/
    └── workflows/
        └── deploy.yml         # GitHub Actions workflow
```

## Monitoring

```bash
# Check pods
kubectl get pods

# Check service
kubectl get svc

# Check ArgoCD sync status
kubectl get applications -n argocd

# View pod logs
kubectl logs -l app=cat-flask

# View ArgoCD logs
kubectl logs -n argocd -l app.kubernetes.io/name=argocd-server
```

## Cleanup

```bash
# Delete Kubernetes resources
kubectl delete -f k8s/

# Delete ArgoCD application
kubectl delete -f argocd/application.yaml

# Uninstall ArgoCD
kubectl delete -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Delete namespace
kubectl delete namespace argocd

# Stop Minikube
minikube stop
```

## Troubleshooting

**GitHub Actions failing:**
- Check secrets are configured correctly
- Verify DockerHub credentials

**ArgoCD not syncing:**
- Check repo URL in `application.yaml`
- Verify ArgoCD has access to repo (public or with credentials)
- Check ArgoCD logs: `kubectl logs -n argocd -l app.kubernetes.io/name=argocd-application-controller`

**Pods not starting:**
- Check image name in `deployment.yaml`
- Verify image exists on DockerHub
- Check pod logs: `kubectl logs -l app=cat-flask`

## APIs Used

- **Cat Facts API:** https://catfact.ninja/facts
- **Dog CEO API:** https://dog.ceo/api/breeds/image/random

## License

MIT
