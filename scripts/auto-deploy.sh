#!/bin/bash

# Fully automated deployment script
# Handles everything: setup, build, deploy

# Exit on error for critical commands
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

# Step 2: Pull latest code (force refresh to ensure we have latest script)
echo "Step 2: Pulling latest code..."
git fetch origin 2>/dev/null || true
git reset --hard origin/develop 2>/dev/null || git reset --hard origin/main 2>/dev/null || git pull origin develop 2>/dev/null || git pull origin main 2>/dev/null || echo "Already up to date"

# Step 3: Always build locally (never pull from registry to avoid auth issues)
echo "Step 3: Preparing for local build..."
# Unset image variables to force local builds
if [ "$ENVIRONMENT" = "test" ]; then
    export BACKEND_TEST_IMAGE=""
    export FRONTEND_TEST_IMAGE=""
else
    export BACKEND_PROD_IMAGE=""
    export FRONTEND_PROD_IMAGE=""
fi
echo "ℹ️  All images will be built locally (no registry pulls)"

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
echo "Stopping existing containers..."
docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true

# Force recreate MySQL container if it exists (to apply new auth plugin)
if [ "$ENVIRONMENT" = "test" ]; then
    echo "Recreating MySQL container with new authentication settings..."
    docker rm -f ticket-mysql-test 2>/dev/null || true
else
    echo "Recreating MySQL container with new authentication settings..."
    docker rm -f ticket-mysql-prod 2>/dev/null || true
fi

# Build our custom images first (always build locally, never pull from registry)
echo "Building custom Docker images (this may take a few minutes)..."
if [ "$ENVIRONMENT" = "test" ]; then
    echo "Building backend image (local build, no pull)..."
    docker compose -f "$COMPOSE_FILE" build --no-cache backend-test 2>&1 | grep -v -i "pull\|login\|authentication" || docker compose -f "$COMPOSE_FILE" build backend-test
    echo "Building frontend image (local build, no pull)..."
    docker compose -f "$COMPOSE_FILE" build --no-cache frontend-test 2>&1 | grep -v -i "pull\|login\|authentication" || docker compose -f "$COMPOSE_FILE" build frontend-test
else
    echo "Building backend image (local build, no pull)..."
    docker compose -f "$COMPOSE_FILE" build --no-cache backend-prod 2>&1 | grep -v -i "pull\|login\|authentication" || docker compose -f "$COMPOSE_FILE" build backend-prod
    echo "Building frontend image (local build, no pull)..."
    docker compose -f "$COMPOSE_FILE" build --no-cache frontend-prod 2>&1 | grep -v -i "pull\|login\|authentication" || docker compose -f "$COMPOSE_FILE" build frontend-prod
fi

# Start services - our custom images are built, MySQL will be pulled if needed (public, no auth)
echo "Starting services..."
export COMPOSE_HTTP_TIMEOUT=300
# Filter out any pull/login messages
docker compose -f "$COMPOSE_FILE" up -d 2>&1 | grep -v -i "pull\|login\|authentication" || docker compose -f "$COMPOSE_FILE" up -d

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
