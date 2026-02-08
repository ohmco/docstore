#!/bin/bash

# Paperless-ngx Maintenance Script
# Performs routine maintenance tasks

set -e

# Configuration
IMAGE_RETENTION_DAYS=30  # Keep images from the last 30 days

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

# Clean up old Docker images (keep images from last $IMAGE_RETENTION_DAYS days)
echo "Cleaning up old Docker images (keeping last ${IMAGE_RETENTION_DAYS} days)..."
docker image prune -af --filter "until=$((IMAGE_RETENTION_DAYS * 24))h"

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
