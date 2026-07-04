# DevOps Assignment - ABC Technologies Website

**Name:** salman malvasi  
**Registration No:** 24bce1277

Corporate website deployed with Git, Jenkins, Docker, Kubernetes, Nagios, Graphite, and Grafana.

## Project Structure

```
website/          HTML pages
Dockerfile        nginx image
Jenkinsfile       CI/CD pipeline
k8s/              Kubernetes manifests
push_metrics.py   sends metrics to Graphite
setup.sh          start all services (macOS)
```

## Quick Start (macOS)

```bash
cd /Users/salman_malvasi/Downloads/RegisterNumber_Name_DevOps_Project
chmod +x setup.sh
./setup.sh
```

## URLs after setup

| Service   | URL                    |
|-----------|------------------------|
| Website   | http://localhost:8081  |
| Nagios    | http://localhost:8082  |
| Graphite  | http://localhost:8083  |
| Grafana   | http://localhost:3000  |

Grafana login: admin / admin  
Nagios login: nagiosadmin / nagios

## Manual commands

```bash
# Build and run website
docker build -t abc-technologies-site:latest .
docker run -d -p 8081:80 --name abc-site abc-technologies-site:latest

# Kubernetes
minikube start --driver=docker
minikube image load abc-technologies-site:latest
kubectl apply -f k8s/
minikube service abc-website-service --url

# Push metrics
python3 push_metrics.py
```

## GitHub repo name

`24bce1277-DevOps-Project`

## Submission files

- ZIP: `24bce1277_salman_malvasi_DevOps_Project.zip`
- Report: `24bce1277_salman_malvasi_DevOps_Report.pdf`
# 24bce177_salman_devops
