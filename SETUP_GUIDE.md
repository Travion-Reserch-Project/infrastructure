# 🚀 Travion Infrastructure - Quick Setup Guide

## Overview

This infrastructure supports deployment on:

- **Local Development** - Docker Compose
- **VPS/Cloud Server** - Docker Compose with Nginx
- **Kubernetes** - K8s manifests provided

---

## 📋 Quick Start

### 1. Local Development

```bash
# Clone repository
git clone <your-repo-url>
cd travion-research-project

# Start all services
cd infrastructure/compose
docker-compose -f docker-compose.dev.yml up -d

# Access services
# Backend API: http://localhost:3001
# ML Service: http://localhost:8000
# Mongo Express: http://localhost:8081 (admin/admin)
```

### 2. VPS/Production Deployment

```bash
# On your VPS (as root or sudo)
curl -o setup_vps.sh https://raw.githubusercontent.com/YOUR_ORG/travion-research-project/main/infrastructure/scripts/setup_vps.sh
chmod +x setup_vps.sh
./setup_vps.sh

# Configure environment variables
cd /opt/travion
nano infrastructure/.env
nano infrastructure/docker/backend/.env
nano infrastructure/docker/ml-services/.env

# Deploy
./infrastructure/scripts/deploy.sh production

# Check status
docker-compose -f infrastructure/compose/docker-compose.prod.yml ps
```

### 3. Kubernetes Deployment

```bash
# Apply Kubernetes manifests
kubectl apply -f infrastructure/k8s/configmap.yml
kubectl apply -f infrastructure/k8s/secrets.yml
kubectl apply -f infrastructure/k8s/mongo-deployment.yml
kubectl apply -f infrastructure/k8s/backend-deployment.yml
kubectl apply -f infrastructure/k8s/ml-deployment.yml
kubectl apply -f infrastructure/k8s/ingress.yml

# Check status
kubectl get pods
kubectl get services
```

---

## 🔧 Configuration

### Environment Variables

**infrastructure/.env**

```env
ENVIRONMENT=production
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=your_secure_password
DOMAIN=travion.com
```

**infrastructure/docker/backend/.env**

```env
NODE_ENV=production
INFISICAL_CLIENT_ID=your_id
INFISICAL_CLIENT_SECRET=your_secret
JWT_SECRET=your_jwt_secret
```

**infrastructure/docker/ml-services/.env**

```env
PYTHON_ENV=production
MODEL_PATH=/app/model
```

---

## 🔐 SSL/TLS Certificates

### Option 1: Let's Encrypt (Recommended for Production)

```bash
# Install certbot
apt-get install certbot

# Get certificate
certbot certonly --webroot \
  -w /var/www/certbot \
  -d api.travion.com \
  -d ml.travion.com

# Certificates will be in /etc/letsencrypt/live/your-domain/
# Copy to infrastructure/docker/nginx/ssl/
```

### Option 2: Self-Signed (Development Only)

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout infrastructure/docker/nginx/ssl/travion.key \
  -out infrastructure/docker/nginx/ssl/travion.crt
```

---

## 📊 Monitoring

### Start Monitoring Stack

```bash
cd infrastructure/monitoring
docker-compose -f docker-compose.monitoring.yml up -d

# Access dashboards
# Grafana: http://your-server:3000 (admin/admin)
# Prometheus: http://your-server:9090
```

---

## 🔄 Common Operations

### View Logs

```bash
# All services
docker-compose -f infrastructure/compose/docker-compose.prod.yml logs -f

# Specific service
docker-compose -f infrastructure/compose/docker-compose.prod.yml logs -f backend
```

### Restart Services

```bash
# All services
docker-compose -f infrastructure/compose/docker-compose.prod.yml restart

# Specific service
docker-compose -f infrastructure/compose/docker-compose.prod.yml restart backend
```

### Update Deployment

```bash
./infrastructure/scripts/deploy.sh production
```

### Backup Database

```bash
./infrastructure/scripts/backup.sh
```

### Restore Database

```bash
./infrastructure/scripts/restore.sh /path/to/backup/file.gz
```

---

## 🛠️ Troubleshooting

### Services not starting

```bash
# Check logs
docker-compose -f infrastructure/compose/docker-compose.prod.yml logs

# Check service health
docker-compose -f infrastructure/compose/docker-compose.prod.yml ps
```

### Port conflicts

```bash
# Check what's using the port
sudo lsof -i :3001
sudo lsof -i :8000
sudo lsof -i :27017

# Kill process
sudo kill -9 <PID>
```

### Database connection issues

```bash
# Check MongoDB status
docker exec -it travion-mongodb-prod mongosh -u admin -p your_password

# Test connection
docker exec -it travion-backend-prod node -e "console.log(process.env.MONGODB_URI)"
```

---

## 📚 Directory Structure

```
infrastructure/
├── docker/              # Dockerfiles and configs
├── compose/             # Docker Compose files
├── k8s/                # Kubernetes manifests
├── ci-cd/              # CI/CD pipelines
├── monitoring/         # Prometheus, Grafana
├── scripts/            # Deployment scripts
├── terraform/          # IaC (optional)
└── ansible/            # Config management (optional)
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch
3. Test locally with `docker-compose.dev.yml`
4. Submit a pull request

---

## 📞 Support

- **Issues**: GitHub Issues
- **Documentation**: See README.md
- **Security**: Report to security@travion.com

---

**Last Updated**: October 2025
