#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
BACKUP_DIR="/opt/travion/infrastructure/scripts/backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RETENTION_DAYS=${BACKUP_RETENTION_DAYS:-30}

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Travion Backup Script${NC}"
echo -e "${GREEN}========================================${NC}"

mkdir -p $BACKUP_DIR

echo -e "${YELLOW}1. Backing up MongoDB...${NC}"
docker exec travion-mongodb-prod mongodump \
    --uri="mongodb://admin:${MONGO_ROOT_PASSWORD}@localhost:27017" \
    --gzip \
    --archive=/backup/mongodb_backup_${TIMESTAMP}.gz

echo -e "${YELLOW}2. Backing up environment files...${NC}"
tar -czf $BACKUP_DIR/env_backup_${TIMESTAMP}.tar.gz \
    infrastructure/.env \
    travion-backend/.env \
    ml-services/transport-service/.env

echo -e "${YELLOW}3. Backing up SSL certificates...${NC}"
if [ -d "infrastructure/templates/docker-reference/nginx/ssl" ]; then
    tar -czf $BACKUP_DIR/ssl_backup_${TIMESTAMP}.tar.gz \
        infrastructure/templates/docker-reference/nginx/ssl/
fi

echo -e "${YELLOW}4. Backing up ML models...${NC}"
docker run --rm \
    -v travion_ml_models:/models \
    -v $BACKUP_DIR:/backup \
    alpine tar -czf /backup/ml_models_${TIMESTAMP}.tar.gz /models

echo -e "${YELLOW}5. Removing old backups (older than $RETENTION_DAYS days)...${NC}"
find $BACKUP_DIR -name "*.gz" -type f -mtime +$RETENTION_DAYS -delete
find $BACKUP_DIR -name "*.tar.gz" -type f -mtime +$RETENTION_DAYS -delete

echo -e "${GREEN}Backup completed successfully!${NC}"
echo -e "${YELLOW}Backup location: $BACKUP_DIR${NC}"
ls -lh $BACKUP_DIR/*_${TIMESTAMP}*
