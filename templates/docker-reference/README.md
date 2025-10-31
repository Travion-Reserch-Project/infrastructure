# Infrastructure Docker Configurations

## Overview

This directory contains centralized Docker configurations and documentation for all services. The actual Dockerfiles are located in each service's directory for easier development.

## Structure

```
infrastructure/docker/
├── backend/
│   ├── .env.example          # Backend environment template
│   └── README.md            # Backend Docker docs
├── ml-services/
│   ├── .env.example          # ML service environment template
│   └── README.md            # ML Docker docs
├── data-pipeline/
│   └── README.md            # Data pipeline Docker docs
└── nginx/
    ├── Dockerfile           # Nginx reverse proxy
    ├── nginx.conf           # Nginx configuration
    └── ssl/                 # SSL certificates
```

## Actual Dockerfile Locations

For development and to keep services self-contained, actual Dockerfiles are in each service directory:

- **Backend**: `travion-backend/Dockerfile`
- **ML Service**: `ml-services/transport-service/Dockerfile`
- **Data Pipeline**: `data-pipeline/Dockerfile`
- **Nginx**: `infrastructure/docker/nginx/Dockerfile`

## Building Services

### From Service Directory (Recommended)
```bash
# Backend
cd travion-backend
docker build -t travion-backend .

# ML Service
cd ml-services/transport-service
docker build -t travion-ml-service .
```

### Using Docker Compose (Easiest)
```bash
# Development
cd infrastructure/compose
docker-compose -f docker-compose.dev.yml up --build

# Production
docker-compose -f docker-compose.prod.yml up --build
```

## Environment Variables

Each service has an `.env.example` file:
- Copy to `.env` in the service directory for local development
- Use infrastructure compose files for orchestrated deployments

## Best Practices

1. **Keep Dockerfiles with services** - Makes development easier
2. **Centralize compose files** - Better orchestration control
3. **Use multi-stage builds** - Smaller production images
4. **Non-root users** - Security best practice
5. **Health checks** - Automatic recovery
