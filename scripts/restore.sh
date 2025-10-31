#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ -z "$1" ]; then
    echo -e "${RED}Usage: $0 <backup_file>${NC}"
    echo -e "${YELLOW}Available backups:${NC}"
    ls -lh /opt/travion/infrastructure/scripts/backup/*.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE=$1

if [ ! -f "$BACKUP_FILE" ]; then
    echo -e "${RED}Backup file not found: $BACKUP_FILE${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Travion Restore Script${NC}"
echo -e "${GREEN}========================================${NC}"

echo -e "${RED}WARNING: This will overwrite existing data!${NC}"
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo -e "${YELLOW}Restore cancelled${NC}"
    exit 0
fi

echo -e "${YELLOW}Restoring from: $BACKUP_FILE${NC}"

# Detect backup type
if [[ $BACKUP_FILE == *"mongodb"* ]]; then
    echo -e "${YELLOW}Restoring MongoDB...${NC}"
    docker exec -i travion-mongodb-prod mongorestore \
        --uri="mongodb://admin:${MONGO_ROOT_PASSWORD}@localhost:27017" \
        --gzip \
        --archive < $BACKUP_FILE
    
elif [[ $BACKUP_FILE == *"ml_models"* ]]; then
    echo -e "${YELLOW}Restoring ML models...${NC}"
    docker run --rm \
        -v travion_ml_models:/models \
        -v $(dirname $BACKUP_FILE):/backup \
        alpine tar -xzf /backup/$(basename $BACKUP_FILE) -C /
    
elif [[ $BACKUP_FILE == *"env"* ]]; then
    echo -e "${YELLOW}Restoring environment files...${NC}"
    tar -xzf $BACKUP_FILE -C /opt/travion/
    
elif [[ $BACKUP_FILE == *"ssl"* ]]; then
    echo -e "${YELLOW}Restoring SSL certificates...${NC}"
    tar -xzf $BACKUP_FILE -C /opt/travion/
fi

echo -e "${GREEN}Restore completed successfully!${NC}"
echo -e "${YELLOW}You may need to restart services:${NC}"
echo -e "docker-compose -f infrastructure/compose/docker-compose.prod.yml restart"
