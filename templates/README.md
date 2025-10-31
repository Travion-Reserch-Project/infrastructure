# 📝 Dockerfile Templates & Standards

This directory contains **reference Dockerfiles** and **best practices** for Travion services. These are **NOT used for building** - each service has its own Dockerfile in its repository.

## 🎯 Purpose

- **Documentation**: Show standard patterns for Travion Dockerfiles
- **Reference**: Template for creating new services
- **Standards**: Enforce security and optimization practices

## 📦 Service Dockerfiles Location

| Service           | Dockerfile Location                        | Build Responsibility         |
| ----------------- | ------------------------------------------ | ---------------------------- |
| **Backend**       | `travion-backend/Dockerfile`               | travion-backend repo + CI/CD |
| **ML Services**   | `ml-services/transport-service/Dockerfile` | ml-services repo + CI/CD     |
| **Data Pipeline** | `data-pipeline/Dockerfile`                 | data-pipeline repo + CI/CD   |
| **Nginx**         | `infrastructure/docker/nginx/`             | infrastructure repo (shared) |

## 🔧 How It Works

### 1. Service Repos Build & Push

Each service repository:

- Maintains its own `Dockerfile`
- Builds Docker images in GitHub Actions
- Pushes to **GHCR** (GitHub Container Registry)

```yaml
# Example: travion-backend/.github/workflows/docker-build.yml
- name: Build and push
  uses: docker/build-push-action@v5
  with:
    context: .
    file: ./Dockerfile # ← In service root
    push: true
    tags: ghcr.io/travion-research-project/travion-backend:latest
```

### 2. Infrastructure Pulls Images

Infrastructure `docker-compose.prod.yml` **pulls pre-built images**:

```yaml
services:
  backend:
    image: ghcr.io/travion-research-project/travion-backend:latest # ← Pulls from GHCR
    # No build context needed!
```

## 📋 Dockerfile Standards

### ✅ Required Best Practices

1. **Multi-stage builds** - Reduce image size
2. **Non-root user** - Security hardening
3. **Health checks** - Container monitoring
4. **Layer optimization** - Faster builds
5. **Security scanning** - Trivy/Snyk in CI

### 📄 Node.js Template

```dockerfile
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY --from=builder /app/dist ./dist

RUN addgroup -g 1001 nodejs && adduser -S nodejs -u 1001
USER nodejs

HEALTHCHECK CMD node -e "require('http').get('http://localhost:3001/health')"
CMD ["node", "dist/server.js"]
```

### 🐍 Python Template

```dockerfile
FROM python:3.9-slim

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential curl \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN useradd -m -u 1001 appuser && chown -R appuser:appuser /app
USER appuser

HEALTHCHECK CMD curl -f http://localhost:8000/health || exit 1
CMD ["python", "app.py"]
```

## 🚫 What NOT to Do

❌ **Don't** duplicate Dockerfiles across repos  
❌ **Don't** build service images in infrastructure repo  
❌ **Don't** use `build:` in production compose files  
❌ **Don't** commit `.env` files

✅ **Do** use templates as reference  
✅ **Do** maintain Dockerfile in service repo  
✅ **Do** use `image:` to pull from GHCR  
✅ **Do** version your images with tags

## 🔄 Workflow

```
┌─────────────────┐
│ Service Repo    │
│ - Edit code     │
│ - Update Dockerfile │
│ - Push to GitHub │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ GitHub Actions  │
│ - Build image   │
│ - Push to GHCR  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Infrastructure  │
│ - Pull image    │
│ - Deploy        │
└─────────────────┘
```

## 📚 Further Reading

- [Docker Multi-stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Security Best Practices](https://docs.docker.com/develop/security-best-practices/)
- [GitHub Container Registry](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

**Last Updated**: October 2025
