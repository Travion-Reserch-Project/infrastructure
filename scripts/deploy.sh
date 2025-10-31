#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Environment (dev/staging/production)
ENV=${1:-production}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deploying Travion - $ENV${NC}"
echo -e "${GREEN}========================================${NC}"

# Determine compose file
if [ "$ENV" == "dev" ] || [ "$ENV" == "development" ]; then
    COMPOSE_FILE="infrastructure/compose/docker-compose.dev.yml"
elif [ "$ENV" == "production" ] || [ "$ENV" == "prod" ]; then
    COMPOSE_FILE="infrastructure/compose/docker-compose.prod.yml"
else
    echo -e "${RED}Invalid environment: $ENV${NC}"
    echo "Usage: $0 [dev|production]"
    exit 1
fi

echo -e "${YELLOW}1. Pulling latest code...${NC}"
git pull origin main

echo -e "${YELLOW}2. Building Docker images...${NC}"
docker-compose -f $COMPOSE_FILE build --no-cache

echo -e "${YELLOW}3. Stopping existing containers...${NC}"
docker-compose -f $COMPOSE_FILE down

echo -e "${YELLOW}4. Starting services...${NC}"
docker-compose -f $COMPOSE_FILE up -d

echo -e "${YELLOW}5. Waiting for services to be healthy...${NC}"
sleep 10

echo -e "${YELLOW}6. Checking service status...${NC}"
docker-compose -f $COMPOSE_FILE ps

echo -e "${YELLOW}7. Verifying health endpoints...${NC}"
for i in {1..30}; do
    if curl -f http://localhost:3001/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Backend is healthy${NC}"
        break
    fi
    echo -e "${YELLOW}Waiting for backend... ($i/30)${NC}"
    sleep 2
done

for i in {1..30}; do
    if curl -f http://localhost:8000/health > /dev/null 2>&1; then
        echo -e "${GREEN}✓ ML Service is healthy${NC}"
        break
    fi
    echo -e "${YELLOW}Waiting for ML service... ($i/30)${NC}"
    sleep 2
done

echo -e "${YELLOW}8. Cleaning up old images...${NC}"
docker image prune -f

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Deployment completed!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Service URLs:${NC}"
echo -e "Backend API: https://$(hostname -I | awk '{print $1}'):443/api"
echo -e "ML Service: https://$(hostname -I | awk '{print $1}'):443/ml"
echo ""
echo -e "${YELLOW}View logs:${NC}"
echo -e "docker-compose -f $COMPOSE_FILE logs -f"
echo ""
