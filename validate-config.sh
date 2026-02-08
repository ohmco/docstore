#!/bin/bash

# Paperless-ngx Configuration Validator
# Checks .env file for common issues and security concerns

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

ERRORS=0
WARNINGS=0

echo -e "${BLUE}╔════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Paperless-ngx Configuration Validator   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════╝${NC}"
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo -e "${RED}✗ Error: .env file not found${NC}"
    echo "  Run: cp .env.example .env"
    echo "  Then edit .env with your settings"
    exit 1
fi

echo -e "${GREEN}✓ Found .env file${NC}"
echo ""

# Load .env
source .env 2>/dev/null || true

# Check required variables
echo "Checking required variables..."

# POSTGRES_PASSWORD
if [ -z "$POSTGRES_PASSWORD" ] || [ "$POSTGRES_PASSWORD" = "changeme_secure_password" ]; then
    echo -e "${RED}✗ POSTGRES_PASSWORD is not set or using default value${NC}"
    echo "  Set a strong, unique password for the database"
    ERRORS=$((ERRORS + 1))
else
    if [ ${#POSTGRES_PASSWORD} -lt 12 ]; then
        echo -e "${YELLOW}⚠ POSTGRES_PASSWORD is too short (< 12 characters)${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ POSTGRES_PASSWORD is set${NC}"
    fi
fi

# PAPERLESS_SECRET_KEY
if [ -z "$PAPERLESS_SECRET_KEY" ] || [ "$PAPERLESS_SECRET_KEY" = "changeme_secret_key_min_32_characters" ]; then
    echo -e "${RED}✗ PAPERLESS_SECRET_KEY is not set or using default value${NC}"
    echo "  Generate with: openssl rand -base64 32"
    ERRORS=$((ERRORS + 1))
else
    if [ ${#PAPERLESS_SECRET_KEY} -lt 32 ]; then
        echo -e "${YELLOW}⚠ PAPERLESS_SECRET_KEY is too short (< 32 characters)${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ PAPERLESS_SECRET_KEY is set${NC}"
    fi
fi

# PAPERLESS_URL
if [ -z "$PAPERLESS_URL" ] || [ "$PAPERLESS_URL" = "http://localhost:8000" ]; then
    echo -e "${YELLOW}⚠ PAPERLESS_URL is set to localhost${NC}"
    echo "  Update this to your actual domain or VPS IP"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ PAPERLESS_URL is set to: $PAPERLESS_URL${NC}"
    
    # Check if using HTTP instead of HTTPS
    if [[ "$PAPERLESS_URL" == http://* ]] && [[ "$PAPERLESS_URL" != *"localhost"* ]] && [[ "$PAPERLESS_URL" != *"127.0.0.1"* ]]; then
        echo -e "${YELLOW}⚠ PAPERLESS_URL uses HTTP instead of HTTPS${NC}"
        echo "  Consider setting up SSL/TLS for production use"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# PAPERLESS_ADMIN_USER
if [ -z "$PAPERLESS_ADMIN_USER" ]; then
    echo -e "${YELLOW}⚠ PAPERLESS_ADMIN_USER is not set, will use 'admin'${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    if [ "$PAPERLESS_ADMIN_USER" = "admin" ]; then
        echo -e "${YELLOW}⚠ PAPERLESS_ADMIN_USER is set to 'admin'${NC}"
        echo "  Consider using a less common username for security"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ PAPERLESS_ADMIN_USER is set${NC}"
    fi
fi

# PAPERLESS_ADMIN_PASSWORD
if [ -z "$PAPERLESS_ADMIN_PASSWORD" ] || [ "$PAPERLESS_ADMIN_PASSWORD" = "changeme_admin_password" ]; then
    echo -e "${RED}✗ PAPERLESS_ADMIN_PASSWORD is not set or using default value${NC}"
    echo "  Set a strong, unique password for the admin user"
    ERRORS=$((ERRORS + 1))
else
    if [ ${#PAPERLESS_ADMIN_PASSWORD} -lt 12 ]; then
        echo -e "${YELLOW}⚠ PAPERLESS_ADMIN_PASSWORD is too short (< 12 characters)${NC}"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}✓ PAPERLESS_ADMIN_PASSWORD is set${NC}"
    fi
fi

# PAPERLESS_ADMIN_MAIL
if [ -z "$PAPERLESS_ADMIN_MAIL" ] || [ "$PAPERLESS_ADMIN_MAIL" = "admin@example.com" ]; then
    echo -e "${YELLOW}⚠ PAPERLESS_ADMIN_MAIL is not set or using default value${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    # Basic email validation
    if [[ "$PAPERLESS_ADMIN_MAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9\.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${GREEN}✓ PAPERLESS_ADMIN_MAIL is set to: $PAPERLESS_ADMIN_MAIL${NC}"
    else
        echo -e "${YELLOW}⚠ PAPERLESS_ADMIN_MAIL doesn't look like a valid email${NC}"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

# PAPERLESS_TIME_ZONE
if [ -z "$PAPERLESS_TIME_ZONE" ]; then
    echo -e "${YELLOW}⚠ PAPERLESS_TIME_ZONE is not set, will use default${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ PAPERLESS_TIME_ZONE is set to: $PAPERLESS_TIME_ZONE${NC}"
fi

# PAPERLESS_OCR_LANGUAGE
if [ -z "$PAPERLESS_OCR_LANGUAGE" ]; then
    echo -e "${YELLOW}⚠ PAPERLESS_OCR_LANGUAGE is not set, will use default${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ PAPERLESS_OCR_LANGUAGE is set to: $PAPERLESS_OCR_LANGUAGE${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check for common weak passwords
echo "Checking for common security issues..."

if [ ! -z "$PAPERLESS_ADMIN_PASSWORD" ]; then
    WEAK_PASSWORDS=("password" "123456" "admin" "changeme" "paperless" "docker")
    for weak in "${WEAK_PASSWORDS[@]}"; do
        if [ "$PAPERLESS_ADMIN_PASSWORD" = "$weak" ]; then
            echo -e "${RED}✗ PAPERLESS_ADMIN_PASSWORD is a commonly used weak password${NC}"
            ERRORS=$((ERRORS + 1))
            break
        fi
    done
fi

# Check if passwords are the same
if [ ! -z "$POSTGRES_PASSWORD" ] && [ ! -z "$PAPERLESS_ADMIN_PASSWORD" ]; then
    if [ "$POSTGRES_PASSWORD" = "$PAPERLESS_ADMIN_PASSWORD" ]; then
        echo -e "${YELLOW}⚠ POSTGRES_PASSWORD and PAPERLESS_ADMIN_PASSWORD are the same${NC}"
        echo "  Use different passwords for different services"
        WARNINGS=$((WARNINGS + 1))
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Summary
echo -e "${BLUE}Summary:${NC}"
if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ Configuration looks good! No issues found.${NC}"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo -e "${YELLOW}⚠ Configuration is usable but has $WARNINGS warning(s)${NC}"
    echo "  Consider addressing the warnings above for better security."
    exit 0
else
    echo -e "${RED}✗ Configuration has $ERRORS error(s) and $WARNINGS warning(s)${NC}"
    echo "  Please fix the errors before deploying."
    exit 1
fi
