#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Travion VPS Setup Script${NC}"
echo -e "${GREEN}========================================${NC}"

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo -e "${RED}Please run as root or with sudo${NC}"
   exit 1
fi

echo -e "${YELLOW}1. Updating system packages...${NC}"
apt-get update && apt-get upgrade -y

echo -e "${YELLOW}2. Installing dependencies...${NC}"
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    ufw \
    fail2ban

echo -e "${YELLOW}3. Installing Docker...${NC}"
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sh get-docker.sh
    rm get-docker.sh
    systemctl enable docker
    systemctl start docker
    echo -e "${GREEN}Docker installed successfully${NC}"
else
    echo -e "${GREEN}Docker already installed${NC}"
fi

echo -e "${YELLOW}4. Installing Docker Compose...${NC}"
if ! command -v docker-compose &> /dev/null; then
    curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}Docker Compose installed successfully${NC}"
else
    echo -e "${GREEN}Docker Compose already installed${NC}"
fi

echo -e "${YELLOW}5. Setting up firewall...${NC}"
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
echo -e "${GREEN}Firewall configured${NC}"

echo -e "${YELLOW}6. Creating application directory...${NC}"
mkdir -p /opt/travion
cd /opt/travion

echo -e "${YELLOW}7. Cloning repository...${NC}"
if [ -d ".git" ]; then
    echo -e "${GREEN}Repository already exists, pulling latest changes...${NC}"
    git pull
else
    read -p "Enter repository URL: " REPO_URL
    git clone $REPO_URL .
fi

echo -e "${YELLOW}8. Setting up environment files...${NC}"
if [ ! -f "infrastructure/.env" ]; then
    cp infrastructure/.env.example infrastructure/.env
    echo -e "${YELLOW}Please edit infrastructure/.env with your configuration${NC}"
fi

if [ ! -f "travion-backend/.env" ]; then
    cp travion-backend/.env.example travion-backend/.env
    echo -e "${YELLOW}Please edit travion-backend/.env with your configuration${NC}"
fi

if [ ! -f "ml-services/transport-service/.env" ]; then
    cp ml-services/transport-service/.env.example ml-services/transport-service/.env
    echo -e "${YELLOW}Please edit ml-services/transport-service/.env with your configuration${NC}"
fi

echo -e "${YELLOW}9. Setting up SSL certificates...${NC}"
mkdir -p infrastructure/templates/docker-reference/nginx/ssl
echo -e "${YELLOW}For production, use: certbot certonly --webroot -w /var/www/certbot -d yourdomain.com${NC}"

echo -e "${YELLOW}10. Setting up log rotation...${NC}"
cat > /etc/logrotate.d/travion << EOF
/opt/travion/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 www-data www-data
    sharedscripts
}
EOF

echo -e "${YELLOW}11. Setting up backup cron job...${NC}"
(crontab -l 2>/dev/null; echo "0 2 * * * /opt/travion/infrastructure/scripts/backup.sh") | crontab -

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Edit environment files in infrastructure/.env and docker/*/.env"
echo -e "2. Set up SSL certificates (certbot or manual)"
echo -e "3. Run: cd /opt/travion && ./infrastructure/scripts/deploy.sh production"
echo ""
