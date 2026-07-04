# DevOps Assignment 2 — Documentation Report

**Student Name:** salman malvasi  
**Registration Number:** 24bce1277  
**Use Case:** Use Case 1 — Corporate Company Website Deployment (ABC Technologies)

---

## Mandatory Submission Links

| Sl. No. | Submission Item | Link / Details |
|---------|-----------------|----------------|
| 1 | GitHub Repository Link | https://github.com/Salmanmalvasi/24bce177_salman_devops |
| 2 | Jenkins Build URL | Local Jenkins at http://localhost:8080 — screenshots attached below |
| 3 | Docker Hub Repository (Optional) | Not used — image built locally |
| 4 | Application URL | http://localhost:8081 |
| 5 | Grafana Dashboard Screenshot | See Section 8 |
| 6 | Nagios Monitoring Screenshot | See Section 7 |
| 7 | Graphite Metrics Screenshot | See Section 7 |

---

## 1. Problem Statement

ABC Technologies has designed a corporate website with HTML, CSS, and JavaScript pages (Home, About Us, Services, Careers, Contact Us, Gallery). The company wants an automated DevOps workflow so that every code update triggers deployment, the site runs in Docker on Kubernetes, and administrators can monitor availability and performance using Nagios, Graphite, and Grafana.

---

## 2. Architecture

```
Developer → Git/GitHub → Jenkins → Docker Build → Kubernetes (Minikube)
                                                          ↓
                                                    Website (nginx)
                                                          ↓
                              Nagios (availability) ← monitoring → Graphite → Grafana
```

**Tools used:** Git, GitHub, Jenkins, Docker, Kubernetes (Minikube), Nagios, Graphite, Grafana

---

## 3. GitHub Repository Setup

- Created repository: https://github.com/Salmanmalvasi/24bce177_salman_devops
- Pushed website source code, Dockerfile, Jenkinsfile, and Kubernetes manifests
- Multiple commits for collaborative development simulation

**Screenshot:** GitHub repo page showing all files  
*(Insert screenshot here)*

---

## 4. Jenkins Pipeline

- Installed Jenkins locally
- Created pipeline job `abc-website-pipeline` using "Pipeline script from SCM"
- Connected to GitHub repo, script path: `Jenkinsfile`
- Pipeline stages: Build Docker Image → Deploy to Kubernetes

**Screenshots needed:**
- Jenkins Dashboard
- Job Configuration page
- Console Output of successful build
- Green "Successful Build" indicator

*(Insert screenshots here)*

---

## 5. Docker Build and Container

```bash
docker build -t abc-technologies-site:latest .
docker run -d -p 8081:80 --name abc-site abc-technologies-site:latest
docker ps
```

- Image: `abc-technologies-site:latest`
- Container port 8081 mapped to nginx port 80
- Website accessible at http://localhost:8081

**Screenshots needed:**
- `docker build` output
- `docker ps` showing running container
- Browser screenshot of website

*(Insert screenshots here)*

---

## 6. Kubernetes Deployment

```bash
minikube start --driver=docker
minikube image load abc-technologies-site:latest
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get services
minikube service abc-website-service --url
```

- Deployment: 2 replicas, `imagePullPolicy: Never`
- Service: NodePort on port 30080
- Both pods in Running state

**Screenshots needed:**
- `kubectl get pods` (Running)
- `kubectl get services`
- Browser showing site via Minikube URL

*(Insert screenshots here)*

---

## 7. Nagios and Graphite Monitoring

### Nagios
- Running in Docker on port 8082
- Monitors website HTTP availability on port 8081
- Login: nagiosadmin / nagios

### Graphite
- Running in Docker on port 8083
- Receives metrics via Carbon on port 2003
- Metrics pushed using `push_metrics.py` (response time, CPU, memory)

**Screenshots needed:**
- Nagios: Host UP, HTTP Service OK (green)
- Graphite: metric graph with data points for `website.response_time_ms`

*(Insert screenshots here)*

---

## 8. Grafana Dashboard

- Running in Docker on port 3000
- Data source: Graphite at http://host.docker.internal:8083
- Dashboard panels: Response Time, CPU %, Memory MB

**Screenshot needed:**
- Grafana dashboard showing all metric panels

*(Insert screenshot here)*

---

## 9. Challenges Faced

1. **Local image in Kubernetes** — Used `imagePullPolicy: Never` and `minikube image load` since image was not pushed to Docker Hub.
2. **Grafana to Graphite connection** — Used `host.docker.internal` on macOS to connect Grafana container to Graphite on host.
3. **Nagios host IP** — Used `host.docker.internal` instead of localhost for Nagios to reach the website container.

---

## 10. Conclusion

The DevOps pipeline was implemented successfully. The ABC Technologies website is version-controlled on GitHub, built automatically via Jenkins, containerized with Docker, deployed on Kubernetes, and monitored using Nagios, Graphite, and Grafana. All required components are running locally and accessible through the browser.

---

## Final Checklist

- [x] GitHub repository accessible
- [x] All source code pushed to GitHub
- [ ] Jenkins build completed successfully (screenshots)
- [x] Docker image created
- [x] Docker container running
- [x] Kubernetes Pods and Services Running
- [x] Application accessible in browser
- [ ] Nagios Host UP / Service OK (screenshot)
- [ ] Graphite receiving metrics (screenshot)
- [ ] Grafana dashboard showing metrics (screenshot)
- [ ] All screenshots added to this report
