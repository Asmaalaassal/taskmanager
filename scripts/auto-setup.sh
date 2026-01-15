#!/bin/bash

# Fully automated setup script
# Generates all secrets, creates env files, and sets up everything

set -e

ENVIRONMENT=${1:-prod}
APP_DIR="/opt/ticket-manager"
ENV_FILE="${APP_DIR}/.env.${ENVIRONMENT}"

echo "=========================================="
echo "Automated Setup for ${ENVIRONMENT} Environment"
echo "=========================================="

# Generate random secrets
generate_secret() {
    openssl rand -hex 32
}

generate_jwt_secret() {
    openssl rand -base64 48 | tr -d "=+/" | cut -c1-64
}

# Check if env file exists, if not create it
if [ ! -f "$ENV_FILE" ]; then
    echo "Creating ${ENV_FILE}..."
    
    # Generate secrets
    MYSQL_ROOT_PASSWORD=$(generate_secret)
    MYSQL_USER="ticket_user_${ENVIRONMENT}"
    MYSQL_PASSWORD=$(generate_secret)
    JWT_SECRET=$(generate_jwt_secret)
    
    # Determine ports and API URL based on environment
    if [ "$ENVIRONMENT" = "test" ]; then
        BACKEND_PORT=8086
        API_URL="http://147.79.101.138:8086/api"
    else
        BACKEND_PORT=8085
        API_URL="http://147.79.101.138:8085/api"
    fi
    
    cat > "$ENV_FILE" << EOF
# Auto-generated environment file for ${ENVIRONMENT}
# Generated on: $(date)

# MySQL Configuration
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD}
MYSQL_USER=${MYSQL_USER}
MYSQL_PASSWORD=${MYSQL_PASSWORD}

# JWT Configuration
JWT_SECRET=${JWT_SECRET}
JWT_EXPIRATION=86400000

# API Configuration
API_URL=${API_URL}
BACKEND_PORT=${BACKEND_PORT}

# GitHub Repository (will be set by deployment)
GITHUB_REPOSITORY=\${GITHUB_REPOSITORY:-your-org/ticket-manager}
EOF
    
    echo "✅ Environment file created: ${ENV_FILE}"
    echo "⚠️  IMPORTANT: Save these credentials securely!"
    echo ""
    echo "MySQL Root Password: ${MYSQL_ROOT_PASSWORD}"
    echo "MySQL User: ${MYSQL_USER}"
    echo "MySQL Password: ${MYSQL_PASSWORD}"
    echo "JWT Secret: ${JWT_SECRET}"
    echo ""
else
    echo "✅ Environment file already exists: ${ENV_FILE}"
    source "$ENV_FILE"
fi

# Create necessary directories
mkdir -p "${APP_DIR}/backups"
mkdir -p "${APP_DIR}/ssl"
mkdir -p "${APP_DIR}/logs"

# Set permissions
chmod 600 "$ENV_FILE" 2>/dev/null || true

echo "✅ Setup completed for ${ENVIRONMENT} environment"
