# 🐳 Docker Architecture - Travion Project

## 🎯 Architecture Overview

Travion follows a **microservices architecture** where each service repository is responsible for its own Docker build process. The infrastructure repository orchestrates deployment without rebuilding images.

```
┌─────────────────────────────────────────────────────────────┐
│                    MICROSERVICES PATTERN                     │
└─────────────────────────────────────────────────────────────┘

┌──────────────────────┐     ┌──────────────────────┐
│  travion-backend     │     │  ml-services         │
│  ├── Dockerfile      │     │  └── transport-service/│
│  ├── .env           │     │      ├── Dockerfile   │
│  └── .github/        │     │      ├── .env        │
│      └── workflows/  │     │      └── .github/    │
│          └── build.yml│     │          └── build.yml│
└──────────┬───────────┘     └──────────┬───────────┘
           │ Builds & Pushes             │ Builds & Pushes
           ▼                             ▼
    ┌──────────────────────────────────────────────┐
    │  GitHub Container Registry (GHCR)            │
    │  ghcr.io/travion-research-project/           │
    │  ├── travion-backend:latest                  │
    │  ├── ml-service:latest                       │
    │  └── data-pipeline:latest                    │
    └──────────────────┬───────────────────────────┘
                       │ Pulls Images
                       ▼
          ┌────────────────────────────┐
          │  infrastructure            │
          │  └── compose/              │
          │      ├── docker-compose.dev.yml  │
          │      └── docker-compose.prod.yml │
          └────────────────────────────┘
```

## 📁 Dockerfile Locations

| Service           | Dockerfile Path                                    | Build Context                    | Image Registry                |
| ----------------- | -------------------------------------------------- | -------------------------------- | ----------------------------- |
| **Backend**       | `travion-backend/Dockerfile`                       | `travion-backend/`               | `ghcr.io/.../travion-backend` |
| **ML Service**    | `ml-services/transport-service/Dockerfile`         | `ml-services/transport-service/` | `ghcr.io/.../ml-service`      |
| **Data Pipeline** | `data-pipeline/Dockerfile`                         | `data-pipeline/`                 | `ghcr.io/.../data-pipeline`   |
| **Nginx**         | `infrastructure/templates/docker-reference/nginx/` | Shared infrastructure            | Built locally                 |

## 🔄 Build & Deploy Workflow

### 1️⃣ Development Flow

**Developer makes changes in service repo:**

```bash
# In travion-backend/
git add .
git commit -m "Add new feature"
git push origin develop
```

**GitHub Actions automatically:**

1. ✅ Builds Docker image from `travion-backend/Dockerfile`
2. ✅ Runs tests
3. ✅ Pushes to GHCR: `ghcr.io/travion-research-project/travion-backend:develop-abc123`
4. ✅ Triggers deployment to dev server

**Dev server updates:**

```bash
cd /opt/travion
docker-compose -f infrastructure/compose/docker-compose.dev.yml pull backend
docker-compose -f infrastructure/compose/docker-compose.dev.yml up -d backend
```

### 2️⃣ Production Release Flow

**Merge to main branch:**

```bash
git checkout main
git merge develop
git push origin main
```

**GitHub Actions automatically:**

1. ✅ Builds production image
2. ✅ Tags as `:latest` and `:v1.2.3`
3. ✅ Security scan with Trivy
4. ✅ Pushes to GHCR
5. ✅ Deploys to production server

## 🛠️ Docker Compose Files

### `docker-compose.dev.yml` - Local Development

**Purpose:** Fast iteration with live code reloading

```yaml
services:
  backend:
    build:
      context: ../../travion-backend # ← Builds locally
      dockerfile: Dockerfile
    volumes:
      - ../../travion-backend/src:/app/src # ← Hot reload
    environment:
      NODE_ENV: development
```

**Usage:**

```bash
cd infrastructure/compose
docker-compose -f docker-compose.dev.yml up --build
```

### `docker-compose.prod.yml` - Production Deployment

**Purpose:** Deploy tested, pre-built images

```yaml
services:
  backend:
    image: ghcr.io/travion-research-project/travion-backend:latest # ← Pulls from GHCR
    restart: always
    env_file:
      - ../../travion-backend/.env # ← Service-specific config
```

**Usage:**

```bash
cd infrastructure/compose
docker-compose -f docker-compose.prod.yml pull  # Get latest images
docker-compose -f docker-compose.prod.yml up -d  # Deploy
```

## 🔐 Environment Variables

### Structure

```
travion-research-project/
├── travion-backend/
│   ├── .env          # ← Backend secrets (gitignored)
│   └── .env.example  # ← Template
├── ml-services/
│   └── transport-service/
│       ├── .env          # ← ML service secrets
│       └── .env.example
└── infrastructure/
    └── .env          # ← Infrastructure secrets (GHCR tokens, etc)
```

### Loading Order

1. **Service `.env` file** - Service-specific configuration
2. **Docker Compose `environment`** - Override specific values
3. **GitHub Secrets** - CI/CD pipeline variables

### Example: Backend .env

```bash
# travion-backend/.env
NODE_ENV=production
PORT=3001

# Infisical
INFISICAL_TOKEN=st.xxxxx
INFISICAL_ENV=prod

# Database
MONGODB_URI=mongodb://mongo:27017/travion

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=https://travion.com
```

## 🏗️ Building Images

### Manual Build (Development)

```bash
# Backend
cd travion-backend
docker build -t travion-backend:local .

# ML Service
cd ml-services/transport-service
docker build -t ml-service:local .
```

### Automated Build (CI/CD)

Handled automatically by GitHub Actions when you push to `develop` or `main`.

**See:** `.github/workflows/docker-build.yml` in each service repo

## 📦 Image Tagging Strategy

| Branch         | Image Tag            | Purpose               |
| -------------- | -------------------- | --------------------- |
| `develop`      | `develop-{sha}`      | Development testing   |
| `main`         | `latest`             | Latest stable release |
| `main`         | `v1.2.3`             | Semantic versioning   |
| `feature/auth` | `feature-auth-{sha}` | Feature testing       |

### Examples

```bash
ghcr.io/travion-research-project/travion-backend:latest
ghcr.io/travion-research-project/travion-backend:v1.2.3
ghcr.io/travion-research-project/travion-backend:develop-abc1234
ghcr.io/travion-research-project/ml-service:latest
```

## 🔍 Troubleshooting

### Issue: Image not found in GHCR

**Error:**

```
Error response from daemon: pull access denied for ghcr.io/travion-research-project/travion-backend
```

**Solution:**

1. Check image was built and pushed:

   ```bash
   # In service repo
   gh workflow view build-and-push
   ```

2. Authenticate with GHCR:

   ```bash
   echo $GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin
   ```

3. Verify image exists:
   ```bash
   docker pull ghcr.io/travion-research-project/travion-backend:latest
   ```

### Issue: Build context errors

**Error:**

```
ERROR: failed to solve: failed to compute cache key: "/package.json" not found
```

**Solution:**
Check build context matches Dockerfile location:

```yaml
# ✅ Correct
build:
  context: ../../travion-backend
  dockerfile: Dockerfile

# ❌ Wrong
build:
  context: ../../
  dockerfile: travion-backend/Dockerfile
```

### Issue: Environment variables not loading

**Error:**

```
Error: Missing environment variable: MONGODB_URI
```

**Solution:**

1. Verify `.env` file exists in service directory
2. Check `env_file` path in docker-compose:

   ```yaml
   env_file:
     - ../../travion-backend/.env # Relative to compose file
   ```

3. Test environment loading:
   ```bash
   docker-compose config  # Shows resolved configuration
   ```

## 🔧 Maintenance

### Updating Dockerfile

**In service repository:**

```bash
cd travion-backend
vim Dockerfile  # Make changes
git add Dockerfile
git commit -m "chore: update Node.js to 20"
git push
```

**CI/CD automatically rebuilds and deploys**

### Cleaning Up Old Images

```bash
# On VPS
docker image prune -a --filter "until=24h"

# Remove specific version
docker rmi ghcr.io/travion-research-project/travion-backend:old-tag
```

### Viewing Image Layers

```bash
docker history ghcr.io/travion-research-project/travion-backend:latest
```

## 📚 Best Practices

### ✅ DO

- ✅ Keep Dockerfile in service root (e.g., `travion-backend/Dockerfile`)
- ✅ Use multi-stage builds to reduce image size
- ✅ Run as non-root user
- ✅ Include health checks
- ✅ Use `.dockerignore` to exclude unnecessary files
- ✅ Tag images with version numbers
- ✅ Use `image:` in production compose (pull from GHCR)
- ✅ Use `build:` in development compose (local builds)

### ❌ DON'T

- ❌ Build service images in infrastructure repo
- ❌ Commit `.env` files
- ❌ Use `:latest` tag in production without version
- ❌ Run containers as root
- ❌ Copy entire workspace into image
- ❌ Hardcode secrets in Dockerfile

## 🔗 Related Documentation

- [CI/CD Pipeline Documentation](../ci-cd/README.md)
- [Deployment Guide](../scripts/README.md)
- [Dockerfile Templates](../templates/README.md)
- [GitHub Container Registry Docs](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry)

---

**Last Updated:** January 2025  
**Maintainer:** Travion Infrastructure Team
