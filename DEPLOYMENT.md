# Paperless-ngx VPS Deployment Guide

This guide will help you deploy Paperless-ngx on a VPS using Docker Compose.

## Prerequisites

- A VPS with at least 2GB RAM and 10GB storage (4GB RAM recommended)
- Ubuntu 20.04 or later (or any Linux distribution with Docker support)
- Root or sudo access
- A domain name (optional, but recommended for HTTPS)

## System Requirements

- Docker Engine 20.10+
- Docker Compose 2.0+
- Nginx (for reverse proxy)

## Installation Steps

### 1. Update Your System

```bash
sudo apt update && sudo apt upgrade -y
```

### 2. Install Docker

```bash
# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to the docker group
sudo usermod -aG docker $USER

# Verify installation
docker --version
```

### 3. Install Docker Compose

```bash
# Docker Compose is included with Docker Engine 20.10+
docker compose version
```

### 4. Clone or Download This Repository

```bash
# If using git
git clone https://github.com/ohmco/docstore.git
cd docstore

# Or download and extract the files manually
```

### 5. Configure Environment Variables

```bash
# Copy the example environment file
cp .env.example .env

# Edit the .env file with your preferred editor
nano .env
```

**Important:** Update the following in your `.env` file:

- `POSTGRES_PASSWORD`: Set a strong database password
- `PAPERLESS_SECRET_KEY`: Generate with `openssl rand -base64 32`
- `PAPERLESS_URL`: Your domain or VPS IP (e.g., `https://paperless.yourdomain.com`)
- `PAPERLESS_ADMIN_USER`: Your admin username
- `PAPERLESS_ADMIN_PASSWORD`: Your admin password
- `PAPERLESS_ADMIN_MAIL`: Your admin email
- `PAPERLESS_TIME_ZONE`: Your timezone

### 6. Create Required Directories

```bash
# Create directories for document consumption and export
mkdir -p consume export
```

### 7. Start Paperless-ngx

```bash
# Start all services
docker compose up -d

# Check if services are running
docker compose ps

# View logs
docker compose logs -f webserver
```

### 8. Access Paperless-ngx

Once the services are running, you can access Paperless-ngx at:

**Note:** By default, Paperless is bound to localhost (127.0.0.1) for security. To access it:
- From the VPS itself: `http://localhost:8000`
- From another machine: Set up the Nginx reverse proxy (see next step) or set `PAPERLESS_BIND_ADDRESS=0.0.0.0` in `.env` (not recommended without a firewall/proxy)

For production, it's strongly recommended to use Nginx as a reverse proxy with SSL/HTTPS (see next step).

Log in with the admin credentials you set in the `.env` file.

## Setting Up Nginx Reverse Proxy (Recommended)

### 1. Install Nginx

```bash
sudo apt install nginx -y
```

### 2. Configure Nginx

```bash
# Copy the nginx configuration
sudo cp nginx.conf /etc/nginx/sites-available/paperless

# Update the domain name in the configuration
sudo nano /etc/nginx/sites-available/paperless

# Enable the site
sudo ln -s /etc/nginx/sites-available/paperless /etc/nginx/sites-enabled/

# Test the configuration
sudo nginx -t

# Restart Nginx
sudo systemctl restart nginx
```

### 3. Configure Firewall

```bash
# Allow HTTP and HTTPS
sudo ufw allow 'Nginx Full'

# Check status
sudo ufw status
```

### 4. Set Up SSL with Let's Encrypt (Recommended)

```bash
# Install certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
# Certbot will automatically detect the nginx configuration and offer to configure HTTPS
sudo certbot --nginx -d your-domain.com

# Follow the prompts:
# - Enter your email address
# - Agree to terms of service
# - Choose whether to redirect HTTP to HTTPS (recommended: yes)
```

Certbot will automatically:
- Obtain the SSL certificate
- Configure Nginx to use HTTPS
- Set up automatic certificate renewal

If you prefer manual configuration, you can uncomment the HTTPS server block in `nginx.conf` and configure it yourself.

## Post-Installation Configuration

### Update Paperless URL

After setting up the domain and SSL, update the `PAPERLESS_URL` in your `.env` file:

```bash
nano .env
# Change PAPERLESS_URL to https://your-domain.com

# Restart the webserver
docker compose restart webserver
```

## Managing Paperless-ngx

### Starting and Stopping

```bash
# Start services
docker compose up -d

# Stop services
docker compose down

# Restart a specific service
docker compose restart webserver

# View logs
docker compose logs -f webserver
```

### Updating Paperless-ngx

**Important:** The default configuration uses `:latest` tag for simplicity. For production, consider pinning to a specific version:

```bash
# Edit docker-compose.yml and change:
# image: ghcr.io/paperless-ngx/paperless-ngx:latest
# to:
# image: ghcr.io/paperless-ngx/paperless-ngx:2.5.3

# Then update
docker compose pull
docker compose up -d

# Clean up old images
docker image prune -a
```

To update with the :latest tag:

```bash
# Pull the latest image
docker compose pull

# Restart with new image
docker compose up -d

# Clean up old images
docker image prune -a
```

### Backup

**Configure Backup Location:**

By default, backups are stored in `/var/backups/paperless` (requires sudo). To use a different location:

```bash
# Set custom backup directory
export BACKUP_DIR=/home/youruser/paperless-backups
./backup.sh
```

**Run Backup:**

```bash
# Default location (may require sudo)
sudo ./backup.sh

# Or with custom location
BACKUP_DIR=/home/youruser/backups ./backup.sh
```

See `backup.sh` for automated backup scripts.

### Adding Documents

You can add documents to Paperless in several ways:

1. **Upload through web interface**: Navigate to the web UI and use the upload button
2. **Consume folder**: Drop files in the `consume/` directory
3. **Email**: Configure email consumption in the admin settings
4. **Mobile app**: Use the official Paperless-ngx mobile app

## Troubleshooting

### Check Service Status

```bash
docker compose ps
```

### View Logs

```bash
# All services
docker compose logs

# Specific service
docker compose logs webserver
docker compose logs db
docker compose logs broker
```

### Reset Admin Password

```bash
docker compose exec webserver python manage.py changepassword admin
```

### Database Issues

```bash
# Restart database
docker compose restart db

# Check database logs
docker compose logs db
```

### Permissions Issues

Ensure the consume and export directories have proper permissions:

```bash
sudo chown -R 1000:1000 consume export
```

## Security Recommendations

1. **Use strong passwords**: For database and admin account
2. **Enable HTTPS**: Use Let's Encrypt for free SSL certificates
3. **Keep updated**: Regularly update Paperless-ngx and system packages
4. **Firewall**: Only expose necessary ports (80, 443)
5. **Backups**: Set up automated backups (see backup.sh)
6. **Limit access**: Consider using VPN or IP whitelisting for admin access

## Resources

- [Paperless-ngx Documentation](https://docs.paperless-ngx.com/)
- [Docker Documentation](https://docs.docker.com/)
- [Let's Encrypt Documentation](https://letsencrypt.org/docs/)

## Support

For issues specific to Paperless-ngx, visit:
- [GitHub Issues](https://github.com/paperless-ngx/paperless-ngx/issues)
- [Documentation](https://docs.paperless-ngx.com/)
