# Paperless-ngx Quick Reference

## Initial Setup

```bash
# Quick automated setup
./setup.sh

# Manual setup
cp .env.example .env
nano .env  # Edit configuration
docker compose up -d
```

## Service Management

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart all services
docker compose restart

# Restart specific service
docker compose restart webserver

# View service status
docker compose ps

# View logs (all services)
docker compose logs -f

# View logs (specific service)
docker compose logs -f webserver
```

## Updates

```bash
# Update to latest version
docker compose pull
docker compose up -d

# Update and clean old images
docker compose pull && docker compose up -d && docker image prune -a
```

## Backup & Restore

```bash
# Create backup (default: /var/backups/paperless, may require sudo)
sudo ./backup.sh

# Create backup to custom location
BACKUP_DIR=/home/user/backups ./backup.sh

# Restore from backup
./restore.sh /var/backups/paperless/paperless_backup_YYYYMMDD_HHMMSS.tar.gz

# List backups
ls -lh /var/backups/paperless/
```

## Maintenance

```bash
# Run maintenance script
./maintenance.sh

# Skip global image cleanup (if you have other Docker projects)
SKIP_IMAGE_PRUNE=1 ./maintenance.sh

# Optimize database
docker compose exec db vacuumdb -U paperless -d paperless -z

# Check disk usage
df -h
docker system df

# Clean up Docker resources (WARNING: global operation)
docker system prune -a
docker volume prune
```

## User Management

```bash
# Reset admin password
docker compose exec webserver python manage.py changepassword admin

# Create new user
docker compose exec webserver python manage.py createsuperuser
```

## Debugging

```bash
# Access webserver shell
docker compose exec webserver bash

# Access database
docker compose exec db psql -U paperless -d paperless

# Check health
curl http://localhost:8000

# View resource usage
docker stats

# Check port availability
sudo netstat -tulpn | grep 8000
```

## File Operations

```bash
# Add documents to consume folder
cp document.pdf consume/

# Check consume folder
ls -la consume/

# Export documents
docker compose exec webserver document_exporter /usr/src/paperless/export

# Fix permissions
sudo chown -R 1000:1000 consume export
```

## Nginx Commands (if using reverse proxy)

```bash
# Test configuration
sudo nginx -t

# Reload configuration
sudo systemctl reload nginx

# Restart Nginx
sudo systemctl restart nginx

# View error logs
sudo tail -f /var/log/nginx/error.log

# View access logs
sudo tail -f /var/log/nginx/access.log
```

## SSL Certificate Management

```bash
# Obtain certificate
sudo certbot --nginx -d yourdomain.com

# Renew certificate (dry run)
sudo certbot renew --dry-run

# Renew certificate
sudo certbot renew

# Check certificate status
sudo certbot certificates
```

## Systemd Service (Optional)

```bash
# Copy service file
sudo cp paperless.service /etc/systemd/system/
sudo nano /etc/systemd/system/paperless.service  # Update path

# Enable and start
sudo systemctl daemon-reload
sudo systemctl enable paperless
sudo systemctl start paperless

# Check status
sudo systemctl status paperless
```

## Emergency Recovery

```bash
# Complete restart
docker compose down
docker compose up -d

# Reset database (CAUTION: deletes all data)
docker compose down -v
docker volume rm docstore_pgdata
docker compose up -d

# Nuclear option (CAUTION: deletes everything)
docker compose down -v
docker volume rm docstore_data docstore_media docstore_pgdata docstore_redisdata
rm -rf consume/* export/*
docker compose up -d
```

## Environment Variables

Key variables in `.env`:

- `POSTGRES_PASSWORD` - Database password
- `PAPERLESS_SECRET_KEY` - Application secret key
- `PAPERLESS_URL` - Public URL
- `PAPERLESS_ADMIN_USER` - Admin username
- `PAPERLESS_ADMIN_PASSWORD` - Admin password
- `PAPERLESS_TIME_ZONE` - Timezone
- `PAPERLESS_OCR_LANGUAGE` - OCR language(s) (plus-separated, e.g., `eng+deu+fra`)
- `PAPERLESS_BIND_ADDRESS` - Port binding (default: `127.0.0.1`, use `0.0.0.0` for external access)

Operational variables:
- `BACKUP_DIR` - Backup location (default: `/var/backups/paperless`)
- `SKIP_IMAGE_PRUNE` - Set to `1` to skip global image cleanup in maintenance.sh

## Useful Paths

- Configuration: `.env`
- Docker Compose: `docker-compose.yml`
- Consume folder: `./consume/`
- Export folder: `./export/`
- Nginx config: `./nginx.conf`
- Backups: `/var/backups/paperless/`

## Common Issues

| Issue | Solution |
|-------|----------|
| Port 8000 in use | Change port in docker-compose.yml |
| Permission denied | `sudo chown -R 1000:1000 consume export` |
| Can't access web | Check firewall: `sudo ufw allow 8000` |
| Database error | Check logs: `docker compose logs db` |
| Out of disk space | `docker system prune -a` |

## Documentation

- 📘 [Full Deployment Guide](DEPLOYMENT.md)
- 🔧 [Troubleshooting Guide](TROUBLESHOOTING.md)
- 📚 [Official Docs](https://docs.paperless-ngx.com/)
