#!/bin/bash

# Paperless-ngx Maintenance Script
# Performs routine maintenance tasks

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Starting Paperless-ngx maintenance...${NC}"

# Update Docker images
echo "Checking for updates..."
docker compose pull

# Restart with new images if updated
echo "Restarting services..."
docker compose up -d

# Wait for services to be healthy
echo "Waiting for services to be ready..."
sleep 30

# Clean up old Docker images
echo "Cleaning up old Docker images..."
docker image prune -af --filter "until=720h"

# Optimize database
echo "Optimizing database..."
docker compose exec -T db vacuumdb -U paperless -d paperless -z -v

# Check disk usage
echo -e "\n${YELLOW}Disk usage:${NC}"
df -h | grep -E "Filesystem|/dev/|docker"

echo -e "\n${YELLOW}Docker volume usage:${NC}"
docker system df -v | head -n 20

# Check service status
echo -e "\n${GREEN}Service status:${NC}"
docker compose ps

echo -e "\n${GREEN}Maintenance completed!${NC}"
