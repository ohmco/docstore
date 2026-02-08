#!/bin/bash

# Paperless-ngx Backup Script
# This script creates backups of Paperless data, media, and database

set -e

# Configuration
BACKUP_DIR="/var/backups/paperless"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="paperless_backup_${DATE}"
RETENTION_DAYS=30

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo "Starting Paperless-ngx backup at $(date)"

# Create backup directory if it doesn't exist
mkdir -p "${BACKUP_DIR}"

# Create a temporary directory for this backup
TEMP_BACKUP_DIR="${BACKUP_DIR}/${BACKUP_NAME}"
mkdir -p "${TEMP_BACKUP_DIR}"

# Export Paperless documents
echo "Exporting documents..."
if ! docker compose exec -T webserver document_exporter /usr/src/paperless/export 2>&1; then
    echo -e "${YELLOW}Warning: Document export failed or produced errors. Continuing with backup...${NC}"
fi

# Backup data volumes
echo "Backing up data volume..."
docker run --rm -v docstore_data:/data -v "${TEMP_BACKUP_DIR}:/backup" ubuntu tar czf /backup/data.tar.gz -C /data .

echo "Backing up media volume..."
docker run --rm -v docstore_media:/media -v "${TEMP_BACKUP_DIR}:/backup" ubuntu tar czf /backup/media.tar.gz -C /media .

# Backup PostgreSQL database
echo "Backing up PostgreSQL database..."
docker compose exec -T db pg_dump -U paperless paperless > "${TEMP_BACKUP_DIR}/paperless_db.sql"

# Backup configuration files
echo "Backing up configuration files..."
cp .env "${TEMP_BACKUP_DIR}/.env.backup" 2>/dev/null || true
cp docker-compose.yml "${TEMP_BACKUP_DIR}/docker-compose.yml.backup"

# Copy exported documents
if [ -d "export" ] && [ "$(ls -A export)" ]; then
    echo "Copying exported documents..."
    cp -r export "${TEMP_BACKUP_DIR}/export_documents"
fi

# Create a compressed archive of the entire backup
echo "Creating compressed archive..."
cd "${BACKUP_DIR}"
tar czf "${BACKUP_NAME}.tar.gz" "${BACKUP_NAME}"
rm -rf "${BACKUP_NAME}"

# Calculate backup size
BACKUP_SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
echo -e "${GREEN}Backup completed successfully!${NC}"
echo "Backup file: ${BACKUP_DIR}/${BACKUP_NAME}.tar.gz"
echo "Backup size: ${BACKUP_SIZE}"

# Clean up old backups
echo "Cleaning up old backups (older than ${RETENTION_DAYS} days)..."
find "${BACKUP_DIR}" -name "paperless_backup_*.tar.gz" -type f -mtime +${RETENTION_DAYS} -delete
echo -e "${GREEN}Backup process completed at $(date)${NC}"

# Clean up export directory
rm -rf export/* 2>/dev/null || true

# Display remaining backups
echo ""
echo "Current backups:"
ls -lh "${BACKUP_DIR}"/paperless_backup_*.tar.gz 2>/dev/null || echo "No backups found"
