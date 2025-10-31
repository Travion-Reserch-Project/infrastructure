# 🏗️ Travion Research Project - Infrastructure

Production-ready infrastructure setup for deploying Travion services on VPS, cloud, or Kubernetes.

## 📁 Directory Structure

```
infrastructure/
├── docker/                     # Docker configurations
├── compose/                    # Docker Compose files
├── k8s/                       # Kubernetes manifests
├── ci-cd/                     # CI/CD pipelines
├── monitoring/                # Monitoring & observability
├── scripts/                   # Deployment & automation scripts
├── terraform/                 # Infrastructure as Code (optional)
└── ansible/                   # Configuration management (optional)
```

## 🚀 Quick Start

### Prerequisites

```bash
# Install required tools
brew install docker docker-compose
brew install terraform  # optional
brew install ansible    # optional
```

### Development Environment

```bash
# Start all services locally
cd compose
docker-compose -f docker-compose.dev.yml up -d

# View logs
docker-compose -f docker-compose.dev.yml logs -f

# Stop services
docker-compose -f docker-compose.dev.yml down
```

### Production Deployment

```bash
# On your VPS, run the setup script
./scripts/setup_vps.sh

# Deploy all services
./scripts/deploy.sh production

# Check status
docker-compose -f compose/docker-compose.prod.yml ps
```

## 📦 Services

| Service     | Port   | Description                   |
| ----------- | ------ | ----------------------------- |
| Backend API | 3001   | Node.js/Express backend       |
| ML Service  | 8000   | Python ML transport service   |
| MongoDB     | 27017  | Database                      |
| Nginx       | 80/443 | Reverse proxy & load balancer |

## 🔐 Security

- All services run as non-root users
- SSL/TLS encryption with Let's Encrypt
- Secrets managed via environment variables
- Network isolation using Docker networks
- Rate limiting on API endpoints

## 📊 Monitoring

Access monitoring dashboards:

- Grafana: `http://your-server:3000`
- Prometheus: `http://your-server:9090`

## 📚 Documentation

- [Docker Setup](./docker/README.md)
- [Kubernetes Deployment](./k8s/README.md)
- [CI/CD Guide](./ci-cd/README.md)
- [Monitoring Setup](./monitoring/README.md)

## 🤝 Contributing

See main repository for contribution guidelines.

---

**Maintained by:** DevOps Team  
**Last Updated:** October 2025
