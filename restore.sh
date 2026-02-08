#!/bin/bash

# Paperless-ngx Restore Script
# This script restores Paperless from a backup

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

if [ $# -eq 0 ]; then
    echo -e "${RED}Error: No backup file specified${NC}"
    echo "Usage: $0 <backup_file.tar.gz>"
    echo ""
    echo "Available backups:"
    ls -lh /var/backups/paperless/paperless_backup_*.tar.gz 2>/dev/null || echo "No backups found"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "${BACKUP_FILE}" ]; then
    echo -e "${RED}Error: Backup file not found: ${BACKUP_FILE}${NC}"
    exit 1
fi

echo -e "${YELLOW}WARNING: This will restore Paperless-ngx from a backup.${NC}"
echo -e "${YELLOW}All current data will be replaced!${NC}"
echo ""
read -p "Are you sure you want to continue? (yes/no): " -r
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Restore cancelled."
    exit 0
fi

echo "Starting restore from ${BACKUP_FILE}..."

# Stop Paperless services
echo "Stopping Paperless services..."
docker compose down

# Extract backup
TEMP_DIR=$(mktemp -d)
echo "Extracting backup to ${TEMP_DIR}..."
tar xzf "${BACKUP_FILE}" -C "${TEMP_DIR}"

BACKUP_NAME=$(basename "${BACKUP_FILE}" .tar.gz)
BACKUP_DIR="${TEMP_DIR}/${BACKUP_NAME}"

# Restore database
if [ -f "${BACKUP_DIR}/paperless_db.sql" ]; then
    echo "Restoring database..."
    # Start only the database
    docker compose up -d db
    sleep 10
    
    # Drop and recreate database
    docker compose exec -T db psql -U paperless -c "DROP DATABASE IF EXISTS paperless;"
    docker compose exec -T db psql -U paperless -c "CREATE DATABASE paperless;"
    
    # Restore database
    cat "${BACKUP_DIR}/paperless_db.sql" | docker compose exec -T db psql -U paperless paperless
    
    docker compose down
fi

# Restore data volume
if [ -f "${BACKUP_DIR}/data.tar.gz" ]; then
    echo "Restoring data volume..."
    docker run --rm -v docstore_data:/data -v "${BACKUP_DIR}:/backup" ubuntu tar xzf /backup/data.tar.gz -C /data
fi

# Restore media volume
if [ -f "${BACKUP_DIR}/media.tar.gz" ]; then
    echo "Restoring media volume..."
    docker run --rm -v docstore_media:/media -v "${BACKUP_DIR}:/backup" ubuntu tar xzf /backup/media.tar.gz -C /media
fi

# Restore configuration files (backup current ones first)
if [ -f "${BACKUP_DIR}/.env.backup" ]; then
    echo "Restoring .env file..."
    [ -f .env ] && cp .env .env.pre-restore
    cp "${BACKUP_DIR}/.env.backup" .env
fi

# Clean up
rm -rf "${TEMP_DIR}"

# Start services
echo "Starting Paperless services..."
docker compose up -d

echo -e "${GREEN}Restore completed successfully!${NC}"
echo "Paperless-ngx is starting up. Check logs with: docker compose logs -f"
echo ""
echo "If you restored .env, verify your settings and restart if needed:"
echo "  docker compose restart"
