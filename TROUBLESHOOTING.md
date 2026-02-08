# Paperless-ngx Troubleshooting Guide

This guide helps resolve common issues when deploying Paperless-ngx.

## Table of Contents

1. [Services Won't Start](#services-wont-start)
2. [Database Connection Issues](#database-connection-issues)
3. [Permission Errors](#permission-errors)
4. [OCR Not Working](#ocr-not-working)
5. [Upload Issues](#upload-issues)
6. [Performance Problems](#performance-problems)
7. [Cannot Access Web Interface](#cannot-access-web-interface)
8. [SSL/HTTPS Issues](#sslhttps-issues)

## Services Won't Start

### Check Docker status

```bash
docker --version
docker compose version
systemctl status docker
```

### Check service logs

```bash
cd /path/to/docstore
docker compose logs
```

### View specific service logs

```bash
docker compose logs webserver
docker compose logs db
docker compose logs broker
```

### Check if ports are in use

```bash
sudo netstat -tulpn | grep :8000
```

If port 8000 is already in use, you can change it in `docker-compose.yml`:

```yaml
ports:
  - "8001:8000"  # Change 8000 to another port
```

### Restart services

```bash
docker compose down
docker compose up -d
```

## Database Connection Issues

### Check database service status

```bash
docker compose ps db
docker compose logs db
```

### Verify database password

Ensure the `POSTGRES_PASSWORD` in `.env` matches what the database expects.

### Reset database (WARNING: This will delete all data)

```bash
docker compose down
docker volume rm docstore_pgdata
docker compose up -d
```

### Connect to database manually

```bash
docker compose exec db psql -U paperless -d paperless
```

## Permission Errors

### Fix consume/export directory permissions

```bash
sudo chown -R 1000:1000 consume export
chmod 755 consume export
```

### Fix Docker volume permissions

```bash
docker compose down
docker run --rm -v docstore_data:/data -v docstore_media:/media ubuntu chown -R 1000:1000 /data /media
docker compose up -d
```

## OCR Not Working

### Check OCR language installation

```bash
docker compose exec webserver bash -c "ls /usr/share/tesseract-ocr/*/tessdata"
```

### Install additional languages

Add to your `.env` file:

```bash
PAPERLESS_OCR_LANGUAGE=eng+fra+deu
```

Then restart:

```bash
docker compose restart webserver
```

### Verify OCR is enabled

In `.env`, ensure:

```bash
PAPERLESS_OCR_LANGUAGE=eng  # or your preferred language(s)
```

## Upload Issues

### Check file size limits

Ensure Nginx allows large files. In `nginx.conf`:

```nginx
client_max_body_size 100M;
```

### Check consume directory

```bash
ls -la consume/
docker compose logs webserver | grep -i consume
```

### Test upload manually

```bash
cp test_document.pdf consume/
docker compose logs -f webserver
```

### Check disk space

```bash
df -h
docker system df
```

## Performance Problems

### Increase memory limits

Add to `docker-compose.yml` under the webserver service:

```yaml
deploy:
  resources:
    limits:
      memory: 2G
```

### Optimize database

```bash
docker compose exec db vacuumdb -U paperless -d paperless -z -v
```

### Check resource usage

```bash
docker stats
```

### Clean up Docker resources

```bash
docker system prune -a
docker volume prune
```

## Cannot Access Web Interface

### Check if service is running

```bash
docker compose ps
curl http://localhost:8000
```

### Check firewall rules

```bash
sudo ufw status
sudo ufw allow 8000/tcp
```

### Check Nginx configuration (if using reverse proxy)

```bash
sudo nginx -t
sudo systemctl status nginx
sudo systemctl restart nginx
```

### Check DNS resolution (if using domain)

```bash
nslookup your-domain.com
```

### Access logs

```bash
# Paperless logs
docker compose logs -f webserver

# Nginx logs (if applicable)
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## SSL/HTTPS Issues

### Verify certificate installation

```bash
sudo certbot certificates
```

### Renew certificate

```bash
sudo certbot renew --dry-run
sudo certbot renew
```

### Check certificate paths in Nginx

```bash
sudo nginx -t
ls -la /etc/letsencrypt/live/your-domain.com/
```

### Force HTTPS redirect

Update `nginx.conf`:

```nginx
server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

## Common Error Messages

### "unable to connect to database"

- Check if database container is running: `docker compose ps db`
- Verify database credentials in `.env`
- Check database logs: `docker compose logs db`

### "Redis connection refused"

- Check if Redis is running: `docker compose ps broker`
- Verify Redis connection string in `.env`

### "Permission denied" on consume folder

```bash
sudo chown -R 1000:1000 consume
chmod 755 consume
```

### "502 Bad Gateway" from Nginx

- Check if Paperless webserver is running: `docker compose ps webserver`
- Verify upstream configuration in `nginx.conf`
- Check Nginx error logs: `sudo tail -f /var/log/nginx/error.log`

### "No space left on device"

```bash
# Check disk space
df -h

# Clean Docker resources
docker system prune -a
docker volume prune

# Remove old log files (use vacuum-size for safer cleanup)
sudo journalctl --vacuum-size=500M
```

## Reset Admin Password

```bash
docker compose exec webserver python manage.py changepassword admin
```

## Complete Reset (Nuclear Option)

⚠️ **WARNING**: This will delete ALL data!

```bash
# Stop and remove everything
docker compose down -v

# Remove all volumes
docker volume rm docstore_data docstore_media docstore_pgdata docstore_redisdata

# Remove consume/export data
rm -rf consume/* export/*

# Start fresh
docker compose up -d
```

## Getting Help

If you're still having issues:

1. Check the [Paperless-ngx documentation](https://docs.paperless-ngx.com/)
2. Search [GitHub Issues](https://github.com/paperless-ngx/paperless-ngx/issues)
3. Join the [Paperless-ngx Discord](https://discord.gg/paperless)

### Collecting Information for Support

When asking for help, provide:

```bash
# System information
uname -a
docker --version
docker compose version

# Service status
docker compose ps

# Recent logs
docker compose logs --tail=100 webserver
docker compose logs --tail=100 db

# Environment (redact sensitive data)
cat .env | grep -v PASSWORD | grep -v SECRET
```
