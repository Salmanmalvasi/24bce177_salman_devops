#!/bin/bash
# Setup script for salman malvasi (24bce1277) - macOS

set -e
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$PROJECT_DIR"

echo "=== Building website Docker image ==="
docker build -t abc-technologies-site:latest .

echo "=== Starting website container ==="
docker rm -f abc-site 2>/dev/null || true
docker run -d -p 8081:80 --name abc-site abc-technologies-site:latest

echo "=== Starting Minikube ==="
minikube start --driver=docker 2>/dev/null || minikube start

echo "=== Deploying to Kubernetes ==="
minikube image load abc-technologies-site:latest
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods
kubectl get services

echo "=== Starting Nagios ==="
docker rm -f nagios 2>/dev/null || true
docker run -d --name nagios -p 8082:80 \
  -v nagios-etc:/opt/nagios/etc \
  -v nagios-var:/opt/nagios/var \
  jasonrivers/nagios:latest

echo "=== Starting Graphite ==="
docker rm -f graphite 2>/dev/null || true
docker run -d --name graphite \
  -p 8083:80 \
  -p 2003-2004:2003-2004 \
  -p 8125:8125/udp \
  graphiteapp/graphite-statsd

echo "=== Starting Grafana ==="
docker rm -f grafana 2>/dev/null || true
docker run -d --name grafana -p 3000:3000 grafana/grafana

echo ""
echo "Done. Services running:"
echo "  Website:  http://localhost:8081"
echo "  Nagios:   http://localhost:8082  (nagiosadmin / nagios)"
echo "  Graphite: http://localhost:8083"
echo "  Grafana:  http://localhost:3000  (admin / admin)"
echo ""
echo "K8s URL: $(minikube service abc-website-service --url 2>/dev/null || echo 'run: minikube service abc-website-service --url')"
echo ""
echo "Run metrics: python3 push_metrics.py"
