#!/bin/bash

# Paperless-ngx Quick Setup Script
# This script helps you get started with Paperless-ngx quickly

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Paperless-ngx Quick Setup Script        ║${NC}"
echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker is not installed.${NC}"
    echo "Would you like to install Docker now? (yes/no)"
    read -r INSTALL_DOCKER
    if [[ $INSTALL_DOCKER =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Installing Docker..."
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        sudo usermod -aG docker "$USER"
        rm get-docker.sh
        echo -e "${GREEN}Docker installed successfully!${NC}"
        echo -e "${YELLOW}Please log out and log back in for group changes to take effect.${NC}"
        echo "Then run this script again."
        exit 0
    else
        echo "Please install Docker manually and run this script again."
        exit 1
    fi
fi

# Check if .env exists
if [ -f .env ]; then
    echo -e "${YELLOW}Configuration file .env already exists.${NC}"
    read -p "Do you want to reconfigure? (yes/no): " RECONFIG
    if [[ ! $RECONFIG =~ ^[Yy][Ee][Ss]$ ]]; then
        echo "Skipping configuration..."
        SKIP_CONFIG=true
    fi
fi

if [ "$SKIP_CONFIG" != "true" ]; then
    # Copy example env file
    cp .env.example .env
    
    echo -e "\n${GREEN}Let's configure your Paperless-ngx installation:${NC}\n"
    
    # Generate secret key
    echo "Generating secure secret key..."
    SECRET_KEY=$(openssl rand -base64 32)
    sed -i "s|changeme_secret_key_min_32_characters|${SECRET_KEY}|g" .env
    
    # Database password
    echo "Generating secure database password..."
    DB_PASSWORD=$(openssl rand -base64 24)
    sed -i "s|changeme_secure_password|${DB_PASSWORD}|g" .env
    
    # Get admin username
    read -p "Enter admin username [admin]: " ADMIN_USER
    ADMIN_USER=${ADMIN_USER:-admin}
    sed -i "s|PAPERLESS_ADMIN_USER=admin|PAPERLESS_ADMIN_USER=${ADMIN_USER}|g" .env
    
    # Get admin password
    echo "Enter admin password (leave empty to generate a random one):"
    read -rs ADMIN_PASSWORD
    echo
    if [ -z "$ADMIN_PASSWORD" ]; then
        ADMIN_PASSWORD=$(openssl rand -base64 16)
        echo -e "${GREEN}Generated admin password: ${ADMIN_PASSWORD}${NC}"
        echo -e "${YELLOW}⚠️  IMPORTANT: Save this password! It will be needed to log in.${NC}"
        read -p "Press Enter to continue..."
    fi
    sed -i "s|changeme_admin_password|${ADMIN_PASSWORD}|g" .env
    
    # Get admin email
    read -p "Enter admin email: " ADMIN_EMAIL
    if [ ! -z "$ADMIN_EMAIL" ]; then
        sed -i "s|admin@example.com|${ADMIN_EMAIL}|g" .env
    fi
    
    # Get URL
    echo ""
    echo "Enter the URL where Paperless will be accessed:"
    echo "  - For local/IP access: http://YOUR_VPS_IP:8000"
    echo "  - For domain: https://paperless.yourdomain.com"
    read -p "URL: " PAPERLESS_URL
    if [ ! -z "$PAPERLESS_URL" ]; then
        sed -i "s|http://localhost:8000|${PAPERLESS_URL}|g" .env
    fi
    
    # Timezone
    echo ""
    read -p "Enter your timezone [America/New_York]: " TIMEZONE
    TIMEZONE=${TIMEZONE:-America/New_York}
    sed -i "s|America/New_York|${TIMEZONE}|g" .env
    
    echo -e "\n${GREEN}Configuration complete!${NC}"
fi

# Create required directories
echo "Creating required directories..."
mkdir -p consume export

# Start services
echo -e "\n${GREEN}Starting Paperless-ngx services...${NC}"
docker compose pull
docker compose up -d

echo -e "\n${YELLOW}Waiting for services to start (this may take a minute)...${NC}"
sleep 10

# Check status
echo -e "\n${GREEN}Service Status:${NC}"
docker compose ps

echo -e "\n${GREEN}╔════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Setup Complete! 🎉                ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════╝${NC}"

# Display access information
echo -e "\n${BLUE}Access Information:${NC}"
if [ ! -z "$PAPERLESS_URL" ]; then
    echo "  URL: ${PAPERLESS_URL}"
else
    echo "  URL: http://$(hostname -I | awk '{print $1}'):8000"
fi
if [ ! -z "$ADMIN_USER" ]; then
    echo "  Username: ${ADMIN_USER}"
else
    echo "  Username: admin"
fi

echo -e "\n${YELLOW}Useful Commands:${NC}"
echo "  View logs:        docker compose logs -f webserver"
echo "  Stop services:    docker compose down"
echo "  Restart services: docker compose restart"
echo "  Update:           docker compose pull && docker compose up -d"
echo ""
echo "For more information, see DEPLOYMENT.md"
