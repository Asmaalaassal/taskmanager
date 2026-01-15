#!/bin/bash

# Fully automated deployment script
# Builds and deploys the application locally (no registry pulls)

set -e

ENVIRONMENT=${1:-test}
APP_DIR="/opt/ticket-manager"
COMPOSE_FILE="${APP_DIR}/docker-compose.${ENVIRONMENT}.yml"
ENV_FILE="${APP_DIR}/.env.${ENVIRONMENT}"

echo "=========================================="
echo "Automated Deployment: ${ENVIRONMENT}"
echo "=========================================="

cd "$APP_DIR" || { echo "❌ Failed to cd to $APP_DIR"; exit 1; }

# Step 1: Setup environment if needed
if [ ! -f "$ENV_FILE" ]; then
    echo "Step 1: Creating environment file..."
    "${APP_DIR}/scripts/auto-setup.sh" "$ENVIRONMENT" || { echo "❌ Setup failed"; exit 1; }
fi

# Load environment variables
source "$ENV_FILE" || { echo "❌ Failed to load $ENV_FILE"; exit 1; }

# Step 2: Backup database (production only)
if [ "$ENVIRONMENT" = "prod" ]; then
    echo "Step 2: Creating database backup..."
    if docker compose -f "$COMPOSE_FILE" ps mysql-prod 2>/dev/null | grep -q "Up"; then
        "${APP_DIR}/scripts/backup-database.sh" prod || echo "⚠️  Backup failed, continuing..."
    fi
fi

# Step 3: Stop existing containers
echo "Step 3: Stopping existing containers..."
docker compose -f "$COMPOSE_FILE" down 2>/dev/null || true

# Step 4: Build images locally
echo "Step 4: Building Docker images locally..."
export COMPOSE_HTTP_TIMEOUT=300

if [ "$ENVIRONMENT" = "test" ]; then
    echo "  Building backend-test..."
    docker compose -f "$COMPOSE_FILE" build --no-cache backend-test 2>&1 | grep -v -i "pull\|login\|authentication" || \
        docker compose -f "$COMPOSE_FILE" build backend-test || { echo "❌ Backend build failed"; exit 1; }
    
    echo "  Building frontend-test..."
    docker compose -f "$COMPOSE_FILE" build --no-cache frontend-test 2>&1 | grep -v -i "pull\|login\|authentication" || \
        docker compose -f "$COMPOSE_FILE" build frontend-test || { echo "❌ Frontend build failed"; exit 1; }
else
    echo "  Building backend-prod..."
    docker compose -f "$COMPOSE_FILE" build --no-cache backend-prod 2>&1 | grep -v -i "pull\|login\|authentication" || \
        docker compose -f "$COMPOSE_FILE" build backend-prod || { echo "❌ Backend build failed"; exit 1; }
    
    echo "  Building frontend-prod..."
    docker compose -f "$COMPOSE_FILE" build --no-cache frontend-prod 2>&1 | grep -v -i "pull\|login\|authentication" || \
        docker compose -f "$COMPOSE_FILE" build frontend-prod || { echo "❌ Frontend build failed"; exit 1; }
fi

# Step 5: Check firewall (warn if needed)
echo "Step 5: Checking firewall..."
if command -v ufw &> /dev/null && ufw status | grep -q "Status: active"; then
    if ! ufw status | grep -q "8086"; then
        echo "⚠️  WARNING: Port 8086 may not be open in firewall!"
        echo "   Run: sudo ufw allow 8086/tcp"
    fi
fi

# Step 6: Start services
echo "Step 6: Starting services..."
docker compose -f "$COMPOSE_FILE" up -d 2>&1 | grep -v -i "pull\|login\|authentication" || \
    docker compose -f "$COMPOSE_FILE" up -d || { echo "❌ Failed to start services"; exit 1; }

# Step 7: Wait for services
echo "Step 7: Waiting for services to initialize..."
sleep 15

# Step 8: Health check
echo "Step 8: Running health checks..."
HEALTH_URL="http://localhost:8086/api/auth/me"
[ "$ENVIRONMENT" = "prod" ] && HEALTH_URL="http://localhost:8085/api/auth/me"

for i in {1..30}; do
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$HEALTH_URL" 2>/dev/null || echo "000")
    if [ "$HTTP_CODE" != "000" ] && [ -n "$HTTP_CODE" ]; then
        echo "✅ Health check passed! (HTTP $HTTP_CODE)"
        break
    fi
    if [ $i -eq 30 ]; then
        echo "⚠️  Health check failed after 30 attempts"
        docker compose -f "$COMPOSE_FILE" ps || true
        exit 1
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Step 9: Show status
echo ""
echo "✅ Deployment completed!"
echo "=========================================="
docker compose -f "$COMPOSE_FILE" ps
echo ""
echo "Access your application:"
if [ "$ENVIRONMENT" = "test" ]; then
    echo "  Frontend: http://147.79.101.138:5174"
    echo "  Backend:  http://147.79.101.138:8086/api"
else
    echo "  Frontend: http://147.79.101.138"
    echo "  Backend:  http://147.79.101.138:8085/api"
fi
echo ""
echo "⚠️  If you can't access from outside, check firewall:"
echo "   Run: ./scripts/fix-firewall.sh"
echo "   Or: sudo ufw allow 8086/tcp"