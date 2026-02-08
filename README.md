# Docstore - Paperless-ngx VPS Deployment

A complete Docker Compose setup for deploying [Paperless-ngx](https://github.com/paperless-ngx/paperless-ngx) on a VPS.

## What is Paperless-ngx?

Paperless-ngx is a document management system that transforms your physical documents into a searchable online archive. It's perfect for:

- 📄 Scanning and organizing paper documents
- 🔍 Full-text search with OCR
- 🏷️ Automatic tagging and organization
- 📱 Mobile app support
- 🔒 Self-hosted and privacy-focused

## Quick Start

1. **Clone this repository**
   ```bash
   git clone https://github.com/ohmco/docstore.git
   cd docstore
   ```

2. **Configure environment**
   ```bash
   cp .env.example .env
   nano .env  # Update with your settings
   ```

3. **Start Paperless**
   ```bash
   docker compose up -d
   ```

4. **Access the application**
   - Open http://your-vps-ip:8000
   - Login with your admin credentials

## Documentation

- 📘 [Deployment Guide](DEPLOYMENT.md) - Complete VPS setup instructions
- 🔧 Configuration files:
  - `docker-compose.yml` - Service definitions
  - `.env.example` - Environment variable template
  - `nginx.conf` - Reverse proxy configuration

## Maintenance Scripts

- `backup.sh` - Automated backup script with retention
- `restore.sh` - Restore from backup
- `maintenance.sh` - Update and optimize system

## Features

✅ Complete Docker Compose setup  
✅ PostgreSQL database  
✅ Redis for caching  
✅ Automatic OCR processing  
✅ Nginx reverse proxy configuration  
✅ SSL/HTTPS support with Let's Encrypt  
✅ Backup and restore scripts  
✅ Health checks and auto-restart  

## System Requirements

- 2GB RAM minimum (4GB recommended)
- 10GB storage minimum
- Docker Engine 20.10+
- Docker Compose 2.0+

## Quick Commands

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# View logs
docker compose logs -f webserver

# Update Paperless
docker compose pull && docker compose up -d

# Backup
./backup.sh

# Restore from backup
./restore.sh /var/backups/paperless/paperless_backup_YYYYMMDD_HHMMSS.tar.gz
```

## Support

For detailed setup instructions, see [DEPLOYMENT.md](DEPLOYMENT.md).

For Paperless-ngx specific issues, visit the [official documentation](https://docs.paperless-ngx.com/).

## License

This deployment configuration is provided as-is for use with Paperless-ngx.
