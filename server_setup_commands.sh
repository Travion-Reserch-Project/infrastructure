#!/bin/bash
# Server Setup Commands for root@194.233.89.41
# Run these commands one by one after SSH connection

# 1. Check current setup
echo "=== Checking current setup ==="
pwd
ls -la /opt/
docker --version
docker compose version
git --version

# 2. Setup /opt/travion directory
echo "=== Setting up /opt/travion ==="
mkdir -p /opt/travion
cd /opt/travion

# 3. Clone infrastructure repository
echo "=== Cloning infrastructure repository ==="
if [ -d ".git" ]; then
    echo "Git repo exists, pulling latest..."
    git pull origin main
else
    git clone https://github.com/Travion-Reserch-Project/infrastructure.git .
fi

# 4. Verify files exist
echo "=== Verifying files ==="
ls -la
ls -la scripts/
ls -la compose/

# 5. Check Docker and Docker Compose
echo "=== Verifying Docker ==="
docker --version
docker compose version
systemctl status docker

# 6. Test docker compose file
echo "=== Testing compose file ==="
docker compose -f compose/docker-compose.prod.yml config

echo "=== Setup complete ==="
