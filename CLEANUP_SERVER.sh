#!/bin/bash

# Server Cleanup Script - Run this on the server via SSH
# WARNING: This will delete all Docker containers, images, and the repository

echo "=========================================="
echo "Server Cleanup Script"
echo "=========================================="
echo "⚠️  WARNING: This will delete:"
echo "  - All Docker containers"
echo "  - All Docker images"
echo "  - The /opt/ticket-manager repository"
echo "  - Docker volumes (database data)"
echo ""
read -p "Are you sure? Type 'yes' to continue: " confirm

if [ "$confirm" != "yes" ]; then
    echo "❌ Cleanup cancelled."
    exit 0
fi

# Stop and remove containers
echo "Step 1: Stopping containers..."
docker compose -f /opt/ticket-manager/docker-compose.test.yml down 2>/dev/null || true
docker compose -f /opt/ticket-manager/docker-compose.prod.yml down 2>/dev/null || true
docker ps -aq | xargs docker rm -f 2>/dev/null || true

# Remove all images
echo "Step 2: Removing Docker images..."
docker images -q | xargs docker rmi -f 2>/dev/null || true

# Remove volumes (includes database data)
echo "Step 3: Removing Docker volumes..."
docker volume ls -q | xargs docker volume rm 2>/dev/null || true

# Remove repository
echo "Step 4: Removing repository..."
rm -rf /opt/ticket-manager

# Clean Docker system
echo "Step 5: Cleaning Docker system..."
docker system prune -a -f --volumes

echo ""
echo "=========================================="
echo "✅ Cleanup complete!"
echo "=========================================="
echo ""
echo "The server is now clean and ready for a fresh deployment."
echo ""
echo "Next steps:"
echo "1. Push your code to GitHub"
echo "2. GitHub Actions will automatically clone and deploy on next push"
