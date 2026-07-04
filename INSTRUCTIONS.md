# DevOps Assignment 2 — Use Case 1: Corporate Website Deployment
## Setup Guide — salman malvasi (24bce1277)

This guide assumes you're on **Windows with WSL2 (Ubuntu)** or a native **Ubuntu** machine. Everything is run locally — that's fine per the assignment instructions (screenshots instead of public URLs).

---

## 0. What you're building

A static website (HTML/CSS/JS) → pushed to GitHub → Jenkins auto-builds a Docker image on every push → image deployed to Kubernetes → Nagios checks if it's up → Graphite collects metrics → Grafana visualizes them.

Project folder structure (already created for you, see attached zip):
```
project/
├── website/        (index.html, about.html, services.html, careers.html, contact.html, gallery.html, style.css, script.js)
├── Dockerfile
├── Jenkinsfile
└── k8s/
    ├── deployment.yaml
    └── service.yaml
```

---

## 1. Install prerequisites

Open a terminal (WSL2 Ubuntu or native Linux) and run:

```bash
sudo apt update && sudo apt upgrade -y

# Git
sudo apt install -y git

# Docker
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker          # apply group without logout

# Java (needed for Jenkins)
sudo apt install -y openjdk-17-jdk

# kubectl
sudo apt install -y curl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Minikube (local Kubernetes cluster)
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube
```

Verify everything:
```bash
git --version
docker --version
java -version
kubectl version --client
minikube version
```

---

## 2. Push the website to GitHub

```bash
cd project
git init
git add .
git commit -m "Initial commit: ABC Technologies website + DevOps pipeline"
```

Go to github.com → New repository → name it `24bce1277-DevOps-Project` → **don't** initialize with README → copy the URL it gives you.

```bash
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/24bce1277-DevOps-Project.git
git push -u origin main
```

📸 **Screenshot needed:** GitHub repo page showing the files.

### To simulate "multiple developers collaborating"
Make at least one small change (e.g. edit text in `index.html`), commit, push again. You can mention in your report that a second branch/PR was used, or actually create a second GitHub account/collaborator if you want it to be literal — usually one extra commit history is enough for the demo.

---

## 3. Install and configure Jenkins

```bash
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null

echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt update
sudo apt install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Let Jenkins use Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins
```

Open browser → `http://localhost:8080`

Get the initial admin password:
```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

Paste it in the browser → **Install suggested plugins** → create your admin user.

Then install extra plugins: **Manage Jenkins → Plugins → Available plugins** → search and install:
- Docker Pipeline
- Git plugin (usually pre-installed)
- Kubernetes CLI plugin

### Add Docker Hub credentials (only needed if pushing image — optional per assignment)
Manage Jenkins → Credentials → System → Global credentials → Add Credentials
- Kind: Username with password
- ID: `dockerhub-creds`
- Your Docker Hub username/password

### Create the pipeline job
1. New Item → name it `abc-website-pipeline` → choose **Pipeline** → OK
2. Under **Pipeline** section, choose "Pipeline script from SCM"
3. SCM: Git → paste your GitHub repo URL
4. Script Path: `Jenkinsfile`
5. Save → click **Build Now**

If you don't want to push to Docker Hub, just delete the "Push to Docker Hub" stage from the Jenkinsfile, and the Kubernetes deploy stage can build+load the image locally instead (see step 5 note on `minikube image load`).

📸 **Screenshots needed:** Jenkins Dashboard, Job Configuration page, Console Output of a successful build, the green "Successful Build" indicator.

---

## 4. Build and run the Docker container manually (to verify before Jenkins)

```bash
cd project
docker build -t abc-technologies-site:latest .
docker run -d -p 8081:80 --name abc-site abc-technologies-site:latest
```

Open `http://localhost:8081` in your browser → you should see the website.

📸 **Screenshots needed:** `docker build` output, `docker ps` showing the running container, browser screenshot of the site.

(Optional) Push to Docker Hub:
```bash
docker login
docker tag abc-technologies-site:latest YOUR_DOCKERHUB_USERNAME/abc-technologies-site:latest
docker push YOUR_DOCKERHUB_USERNAME/abc-technologies-site:latest
```

---

## 5. Deploy to Kubernetes (Minikube)

```bash
minikube start --driver=docker
```

Since this is a local image, load it directly into Minikube's Docker environment instead of pulling from Docker Hub:
```bash
minikube image load abc-technologies-site:latest
```

Edit `k8s/deployment.yaml` and change the image line to just:
```yaml
image: abc-technologies-site:latest
```
and add `imagePullPolicy: Never` right below it, so Kubernetes uses your local image instead of trying to pull from the internet.

Apply the manifests:
```bash
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```

Check status:
```bash
kubectl get pods
kubectl get deployments
kubectl get services
```

Access the website:
```bash
minikube service abc-website-service --url
```
This prints a URL like `http://192.168.49.2:30080` — open it in your browser.

📸 **Screenshots needed:** `kubectl get pods` (Running state), `kubectl get services`, browser showing the site via the Minikube URL.

---

## 6. Install Nagios (monitor website availability)

Easiest path: run Nagios in Docker.

```bash
docker run -d --name nagios -p 8082:80 \
  -v nagios-etc:/opt/nagios/etc \
  -v nagios-var:/opt/nagios/var \
  jasonrivers/nagios:latest
```

Open `http://localhost:8082` — login: `nagiosadmin` / `nagios` (default; check image docs if different).

To monitor your website's host, you need to add a config. Get a shell into the container:
```bash
docker exec -it nagios bash
cd /opt/nagios/etc/objects
```

Create a file `mywebsite.cfg` (use `vi` or `cat >` inside the container):
```cfg
define host {
    use                     linux-server
    host_name               abc-website-host
    address                 172.17.0.1
    max_check_attempts      5
    check_period            24x7
    notification_interval   30
    notification_period     24x7
}

define service {
    use                     generic-service
    host_name               abc-website-host
    service_description     HTTP
    check_command            check_http!-p 8081
}
```
(`172.17.0.1` is usually the Docker host gateway IP from inside a container — adjust if needed by running `ip route` inside the container and using the default gateway. `-p 8081` matches the port your site is running on from step 4.)

Add this include to `nagios.cfg` if not auto-included:
```bash
echo "cfg_file=/opt/nagios/etc/objects/mywebsite.cfg" >> /opt/nagios/etc/nagios.cfg
```

Restart Nagios:
```bash
exit
docker restart nagios
```

Refresh the Nagios web UI → go to **Services** → you should see your host UP and HTTP service OK (green).

📸 **Screenshot needed:** Nagios UI showing Host UP and Service OK in green.

---

## 7. Install Graphite (metrics storage)

```bash
docker run -d --name graphite \
  -p 8083:80 \
  -p 2003-2004:2003-2004 \
  -p 2023-2024:2023-2024 \
  -p 8125:8125/udp \
  -p 8126:8126 \
  graphiteapp/graphite-statsd
```

Open `http://localhost:8083` — that's the Graphite web UI (Composer).

Send a test metric manually to confirm it's receiving data:
```bash
echo "test.metric 42 $(date +%s)" | nc -q0 localhost 2003
```

In the Graphite UI → Tree on the left → expand `test` → click `metric` → it should plot a single point. This confirms Graphite is receiving data.

For real metrics from your site, the simplest approach for an assignment is to write a small cron/script that pings the site and pushes a response-time metric to Graphite every minute:
```bash
cat > /home/$USER/push_metrics.sh << 'EOF'
#!/bin/bash
while true; do
  START=$(date +%s%N)
  curl -s -o /dev/null http://localhost:8081
  END=$(date +%s%N)
  RESP_MS=$(( (END - START) / 1000000 ))
  echo "website.response_time_ms $RESP_MS $(date +%s)" | nc -q0 localhost 2003
  sleep 10
done
EOF
chmod +x /home/$USER/push_metrics.sh
nohup /home/$USER/push_metrics.sh &
```

Let it run for a couple minutes, then check `website.response_time_ms` in the Graphite tree.

📸 **Screenshot needed:** Graphite UI showing the metric graph with data points.

---

## 8. Install Grafana (dashboards)

```bash
docker run -d --name grafana -p 3000:3000 grafana/grafana
```

Open `http://localhost:3000` — default login `admin` / `admin` (it'll ask you to change the password).

### Connect Grafana to Graphite
- Left menu → Connections → Data sources → Add data source → choose **Graphite**
- URL: `http://host.docker.internal:8083` (on Linux, use the host's Docker bridge IP instead if `host.docker.internal` doesn't resolve — find it via `docker network inspect bridge` and use that gateway IP, e.g. `http://172.17.0.1:8083`)
- Save & Test → should say it's working

### Build the dashboard
- Dashboards → New → New Dashboard → Add visualization → pick the Graphite data source
- Query: `website.response_time_ms` → Run query → you'll see the graph
- Add more panels for CPU/Memory/Network if you also installed something like `node_exporter` + Prometheus, but for this assignment, the Graphite-fed metrics (response time, plus you can simulate CPU/memory by pushing `website.cpu_percent` and `website.memory_mb` from a small script using `psutil` in Python, or just `top`/`free` parsed in bash) are enough to satisfy "CPU, Memory, Network Usage, HTTP Availability, Uptime" panels.

Example to also push CPU/memory metrics into the same script from step 7:
```bash
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEM=$(free -m | awk '/Mem:/ {print $3}')
echo "website.cpu_percent $CPU $(date +%s)" | nc -q0 localhost 2003
echo "website.memory_mb $MEM $(date +%s)" | nc -q0 localhost 2003
```
Add these two lines inside the `while true; do ... done` loop in `push_metrics.sh`.

Name the dashboard "ABC Technologies Monitoring" and save it.

📸 **Screenshot needed:** Grafana dashboard showing the panels (response time / CPU / memory / network).

---

## 9. Final checklist before writing your report

- [ ] GitHub repo pushed and accessible
- [ ] Jenkins job built successfully (screenshots: dashboard, config, console output, success)
- [ ] Docker image built, container running (`docker ps` screenshot)
- [ ] Kubernetes pods/services Running (`kubectl get pods/services` screenshot)
- [ ] Website visible in browser via Minikube URL
- [ ] Nagios shows Host UP, Service OK (green)
- [ ] Graphite shows metric data points
- [ ] Grafana dashboard shows the panels

## 10. Report structure (suggested)

1. Title page with the 7 mandatory links/screenshots table from the instructions
2. Problem statement (copy Use Case 1 text)
3. Architecture diagram (Git → Jenkins → Docker → Kubernetes → Nagios/Graphite/Grafana) — draw this in draw.io or PowerPoint
4. Step-by-step implementation with screenshots for every step above
5. Challenges faced and how you solved them (this is genuinely expected — mention things like configuring Nagios host IP, connecting Grafana to Graphite, etc.)
6. Conclusion

## Naming your submission
- ZIP: `24bce1277_salman_malvasi_DevOps_Project.zip` (zip the project folder)
- Report: `24bce1277_salman_malvasi_DevOps_Report.pdf`
- GitHub repo: `24bce1277-DevOps-Project`

---

## Troubleshooting notes

- If `docker` commands need `sudo` every time, you didn't re-login after `usermod -aG docker $USER` — run `newgrp docker` or log out/in.
- If Minikube won't start, check `minikube start --driver=docker` logs; you may need `sudo apt install -y conntrack`.
- If Jenkins can't run `docker` commands, double check `sudo usermod -aG docker jenkins` then `sudo systemctl restart jenkins`.
- If Nagios/Graphite/Grafana containers can't see each other or your host's port 8081, on Linux use the Docker bridge gateway IP (`docker network inspect bridge | grep Gateway`) instead of `localhost` from inside containers.
