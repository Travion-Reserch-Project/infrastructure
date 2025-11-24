# Quick Start Guide - Server Setup

## 🚀 First Time Setup on Server

### Step 1: Configure MongoDB Credentials

```bash
cd /opt/travion

# Edit main .env file
nano .env
```

Set these values:
```bash
MONGO_ROOT_USERNAME=admin
MONGO_ROOT_PASSWORD=YourSecurePassword123
```

Save and exit (Ctrl+X, Y, Enter)

### Step 2: Verify Docker Images Exist

Before deploying, make sure your backend repo has built and pushed the Docker image:

1. Go to https://github.com/Travion-Reserch-Project/travion-backend/actions
2. Check if the "Build Only - No Deployment" workflow has run successfully
3. Verify the image exists: https://github.com/orgs/Travion-Reserch-Project/packages

### Step 3: Manual First Deployment

```bash
cd /opt/travion

# Pull images (only MongoDB will work initially)
docker compose -f compose/docker-compose.prod.yml pull mongodb

# Start MongoDB first
docker compose -f compose/docker-compose.prod.yml up -d mongodb

# Wait for MongoDB to be ready
sleep 10

# Check MongoDB status
docker compose -f compose/docker-compose.prod.yml ps
docker compose -f compose/docker-compose.prod.yml logs mongodb
```

### Step 4: After Backend Image is Built

Once your backend repo builds and pushes the Docker image:

```bash
cd /opt/travion

# Pull backend image
docker compose -f compose/docker-compose.prod.yml pull backend

# Start backend
docker compose -f compose/docker-compose.prod.yml up -d backend

# Check status
docker compose -f compose/docker-compose.prod.yml ps

# View logs
docker compose -f compose/docker-compose.prod.yml logs -f backend
```

## 🔍 Troubleshooting

### Check if image exists in GHCR:
```bash
docker manifest inspect ghcr.io/travion-research-project/travion-backend:latest
```

### View all running containers:
```bash
docker ps

### Stop all services:
```bash
cd /opt/travion
docker compose -f compose/docker-compose.prod.yml down
```

### View logs for specific service:
```bash
docker compose -f compose/docker-compose.prod.yml logs -f backend
docker compose -f compose/docker-compose.prod.yml logs -f mongodb
```

## ✅ Next Steps After Initial Setup

After the first manual setup, GitHub Actions will handle deployments automatically when you push to your backend repo.
