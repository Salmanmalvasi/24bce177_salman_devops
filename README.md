# DevOps Assignment 2 — Use Case 1: ABC Technologies Website

**Name:** salman malvasi  
**Registration No:** 24bce1277  
**Use Case:** Corporate Company Website Deployment

## Mandatory Submission Links

| Sl. No. | Submission Item | Link / Details |
|---------|-----------------|----------------|
| 1 | GitHub Repository | https://github.com/Salmanmalvasi/24bce177_salman_devops |
| 2 | Jenkins Build | Local Jenkins — see screenshots in report (Dashboard, Job Config, Console Output, Successful Build) |
| 3 | Docker Hub (Optional) | Not pushed — image built locally as `abc-technologies-site:latest` |
| 4 | Application URL | http://localhost:8081 (Docker) / Minikube NodePort: `minikube service abc-website-service --url` |
| 5 | Grafana Dashboard | http://localhost:3000 — screenshot in report |
| 6 | Nagios Monitoring | http://localhost:8082 — screenshot in report |
| 7 | Graphite Metrics | http://localhost:8083 — screenshot in report |

## Project Structure

```
website/          HTML pages (Home, About, Services, Careers, Contact, Gallery)
Dockerfile        nginx container
Jenkinsfile       CI/CD pipeline
k8s/              Kubernetes deployment + NodePort service
nagios/           Nagios host config
push_metrics.py   sends metrics to Graphite
setup.sh          start all services (macOS)
INSTRUCTIONS.md   step-by-step setup guide
REPORT.md         documentation report template
```

## Quick Start

```bash
chmod +x setup.sh
./setup.sh
python3 push_metrics.py   # in a separate terminal
```

## Service URLs

| Service | URL | Login |
|---------|-----|-------|
| Website | http://localhost:8081 | — |
| Nagios | http://localhost:8082 | nagiosadmin / nagios |
| Graphite | http://localhost:8083 | — |
| Grafana | http://localhost:3000 | admin / admin |

## Manual Steps

```bash
# Docker
docker build -t abc-technologies-site:latest .
docker run -d -p 8081:80 --name abc-site abc-technologies-site:latest

# Kubernetes
minikube start --driver=docker
minikube image load abc-technologies-site:latest
kubectl apply -f k8s/
kubectl get pods
minikube service abc-website-service --url

# Jenkins: create pipeline job from SCM, point to this repo, script path = Jenkinsfile
```

## Submission Naming

- ZIP: `24bce1277_salman_malvasi_DevOps_Project.zip`
- Report: `24bce1277_salman_malvasi_DevOps_Report.pdf`
