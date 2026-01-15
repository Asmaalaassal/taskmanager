#!/bin/bash

# First-time server setup - run this once on a fresh VPS
# This prepares the server for automated deployments

set -e

echo "=========================================="
echo "First-Time Server Setup"
echo "=========================================="

# Update system
echo "Updating system..."
# Fix any broken repositories first
if [ -f /etc/apt/sources.list.d/monarx.list ]; then
    echo "Fixing broken repository..."
    rm -f /etc/apt/sources.list.d/monarx.list 2>/dev/null || true
fi

# Fix broken package states
echo "Fixing broken package states..."
dpkg --configure -a 2>/dev/null || true
apt-get install -f -y 2>/dev/null || true

apt-get update || (echo "Warning: Some repositories failed, continuing..." && apt-get update --allow-releaseinfo-change 2>/dev/null || true)
apt-get upgrade -y

# Install required packages
echo "Installing packages..."

# Remove conflicting docker-compose packages if they exist
echo "Removing conflicting docker-compose packages..."
dpkg --remove docker-compose-v2 2>/dev/null || true
apt-get remove -y docker-compose-v2 2>/dev/null || true

# Install Docker and docker-compose-plugin (newer method)
apt-get install -y \
    docker.io \
    docker-compose-plugin \
    git \
    curl \
    wget \
    mysql-client \
    gzip \
    unzip \
    openssl \
    ca-certificates

# Start and enable Docker
echo "Setting up Docker..."
systemctl start docker
systemctl enable docker

# Create application directory
echo "Creating directories..."
mkdir -p /opt/ticket-manager
mkdir -p /opt/ticket-manager/backups
mkdir -p /opt/ticket-manager/ssl
mkdir -p /opt/ticket-manager/logs
mkdir -p /opt/ticket-manager/scripts

# Clone repository if URL provided
if [ -n "$1" ]; then
    echo "Cloning repository..."
    cd /opt
    if [ -d "ticket-manager/.git" ]; then
        echo "Repository already exists, skipping clone"
    else
        git clone "$1" ticket-manager || echo "Clone failed, will be done during deployment"
    fi
fi

# Make scripts executable
cd /opt/ticket-manager
chmod +x scripts/*.sh 2>/dev/null || true

echo ""
echo "=========================================="
echo "✅ Server setup completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure GitHub Secrets in your repository"
echo "2. Push to develop branch to trigger test deployment"
echo "3. Everything else will be automated!"
echo ""
