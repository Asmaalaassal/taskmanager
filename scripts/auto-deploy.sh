#!/bin/bash

# Fully automated deployment script
# Handles everything: setup, build, deploy

set -e

ENVIRONMENT=${1:-test}
APP_DIR="/opt/ticket-manager"
COMPOSE_FILE="${APP_DIR}/docker-compose.${ENVIRONMENT}.yml"
ENV_FILE="${APP_DIR}/.env.${ENVIRONMENT}"

echo "=========================================="
echo "Automated Deployment: ${ENVIRONMENT}"
echo "=========================================="

cd "$APP_DIR"

# Step 1: Run auto-setup if needed
echo "Step 1: Checking environment setup..."
if [ ! -f "$ENV_FILE" ]; then
    echo "Environment file not found. Running auto-setup..."
    "${APP_DIR}/scripts/auto-setup.sh" "$ENVIRONMENT"
fi

# Load environment variables
source "$ENV_FILE"

# Step 2: Pull latest code
echo "Step 2: Pulling latest code..."
git pull origin main 2>/dev/null || git pull origin develop 2>/dev/null || echo "Already up to date"

# Step 3: Try to pull images, if they don't exist, build locally
echo "Step 3: Checking Docker images..."

# Check if we can pull from registry (skip if images don't exist - will build locally)
BACKEND_IMAGE="ghcr.io/${GITHUB_REPOSITORY:-your-org/ticket-manager}-backend-${ENVIRONMENT}:latest"
FRONTEND_IMAGE="ghcr.io/${GITHUB_REPOSITORY:-your-org/ticket-manager}-frontend-${ENVIRONMENT}:latest"

# Try to pull backend image (suppress all output and errors, skip if not authenticated)
echo "Checking for backend image in registry..."
# Use --quiet flag and redirect stderr to avoid authentication prompts
if timeout 10 docker pull --quiet "$BACKEND_IMAGE" 2>/dev/null; then
    echo "✅ Backend image found in registry"
    if [ "$ENVIRONMENT" = "test" ]; then
        export BACKEND_TEST_IMAGE="$BACKEND_IMAGE"
    else
        export BACKEND_PROD_IMAGE="$BACKEND_IMAGE"
    fi
else
    echo "ℹ️  Backend image not in registry, will build locally"
    if [ "$ENVIRONMENT" = "test" ]; then
        export BACKEND_TEST_IMAGE=""
    else
        export BACKEND_PROD_IMAGE=""
    fi
fi

# Try to pull frontend image (suppress all output and errors, skip if not authenticated)
echo "Checking for frontend image in registry..."
# Use --quiet flag and redirect stderr to avoid authentication prompts
if timeout 10 docker pull --quiet "$FRONTEND_IMAGE" 2>/dev/null; then
    echo "✅ Frontend image found in registry"
    if [ "$ENVIRONMENT" = "test" ]; then
        export FRONTEND_TEST_IMAGE="$FRONTEND_IMAGE"
    else
        export FRONTEND_PROD_IMAGE="$FRONTEND_IMAGE"
    fi
else
    echo "ℹ️  Frontend image not in registry, will build locally"
    if [ "$ENVIRONMENT" = "test" ]; then
        export FRONTEND_TEST_IMAGE=""
    else
        export FRONTEND_PROD_IMAGE=""
    fi
fi

# Step 4: Backup database if production
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "Step 4: Creating database backup..."
    if docker compose -f "$COMPOSE_FILE" ps mysql-prod 2>/dev/null | grep -q "Up"; then
        "${APP_DIR}/scripts/backup-database.sh" prod || echo "⚠️  Backup failed, continuing..."
    fi
fi

# Step 5: Deploy
echo "Step 5: Deploying services..."
export GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-your-org/ticket-manager}"

# Stop existing containers
docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true

# Start services (will build if images don't exist)
docker compose -f "$COMPOSE_FILE" up -d --build

# Step 6: Wait for services
echo "Step 6: Waiting for services to be ready..."
sleep 15

# Step 7: Health check
echo "Step 7: Running health checks..."
if [ "$ENVIRONMENT" = "test" ]; then
    HEALTH_URL="http://localhost:8086/api/auth/me"
else
    HEALTH_URL="http://localhost:8085/api/auth/me"
fi

for i in {1..30}; do
    if curl -f "$HEALTH_URL" > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  Health check failed after 30 attempts"
    else
        echo "Waiting for service... ($i/30)"
        sleep 2
    fi
done

# Step 8: Show status
echo ""
echo "Step 8: Deployment Status"
echo "=========================================="
docker compose -f "$COMPOSE_FILE" ps

echo ""
echo "✅ Deployment completed!"
echo ""
echo "Access your application:"
if [ "$ENVIRONMENT" = "test" ]; then
    echo "  Frontend: http://147.79.101.138:5174"
    echo "  Backend:  http://147.79.101.138:8086/api"
else
    echo "  Frontend: http://147.79.101.138"
    echo "  Backend:  http://147.79.101.138:8085/api"
fi
