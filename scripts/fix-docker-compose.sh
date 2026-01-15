#!/bin/bash

# Fix docker-compose installation conflicts
# Run this if you get docker-compose package conflicts

set -e

echo "Fixing docker-compose installation..."

# Remove conflicting packages
echo "Removing conflicting packages..."
dpkg --remove docker-compose-v2 2>/dev/null || true
apt-get remove -y docker-compose-v2 docker-compose 2>/dev/null || true

# Fix broken states
dpkg --configure -a
apt-get install -f -y

# Install docker-compose-plugin (newer method)
echo "Installing docker-compose-plugin..."
apt-get install -y docker-compose-plugin

# Verify installation
echo "Verifying docker-compose installation..."
docker compose version || echo "Note: Use 'docker compose' (with space) instead of 'docker-compose'"

echo "✅ Docker compose fixed!"
echo ""
echo "Note: Use 'docker compose' (with space) instead of 'docker-compose' (with hyphen)"
echo "Example: docker compose -f docker-compose.prod.yml up -d"
