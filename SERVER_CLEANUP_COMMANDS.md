# Server Cleanup Commands

## Quick Cleanup (Run on Server)

SSH into your server and run these commands:

```bash
ssh root@147.79.101.138

# 1. Stop all containers
docker compose -f /opt/ticket-manager/docker-compose.test.yml down 2>/dev/null || true
docker compose -f /opt/ticket-manager/docker-compose.prod.yml down 2>/dev/null || true

# 2. Remove all containers
docker ps -aq | xargs docker rm -f 2>/dev/null || true

# 3. Remove all Docker images
docker images -q | xargs docker rmi -f 2>/dev/null || true

# 4. Remove all volumes (⚠️ This deletes database data!)
docker volume ls -q | xargs docker volume rm 2>/dev/null || true

# 5. Remove repository
rm -rf /opt/ticket-manager

# 6. Clean Docker system
docker system prune -a -f --volumes

# Verify cleanup
docker ps -a
docker images
docker volume ls
```

## One-Line Cleanup (All-in-One)

```bash
ssh root@147.79.101.138 'cd /opt && docker compose -f ticket-manager/docker-compose.test.yml down 2>/dev/null; docker compose -f ticket-manager/docker-compose.prod.yml down 2>/dev/null; docker ps -aq | xargs docker rm -f 2>/dev/null; docker images -q | xargs docker rmi -f 2>/dev/null; docker volume ls -q | xargs docker volume rm 2>/dev/null; rm -rf ticket-manager; docker system prune -a -f --volumes; echo "✅ Cleanup complete!"'
```

## Using the Cleanup Script

If you want to use the provided script:

```bash
# On your local machine, push the script first, then:
ssh root@147.79.101.138

# Download the script
cd /tmp
wget https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/CLEANUP_SERVER.sh
# OR copy it manually

chmod +x CLEANUP_SERVER.sh
./CLEANUP_SERVER.sh
```

## After Cleanup

Once cleanup is complete:

1. **Push your code:**
   ```bash
   git add .
   git commit -m "Optimize workflows and cleanup"
   git push origin develop
   ```

2. **GitHub Actions will:**
   - Run tests
   - Clone repository fresh
   - Build images locally
   - Deploy automatically

3. **First deployment will take longer** (building images from scratch)

## Preserve Database Data

If you want to keep your database data, **skip step 4** (volume removal):

```bash
# Stop containers only
docker compose -f /opt/ticket-manager/docker-compose.test.yml down
docker compose -f /opt/ticket-manager/docker-compose.prod.yml down

# Remove repository and images
rm -rf /opt/ticket-manager
docker images -q | xargs docker rmi -f 2>/dev/null || true

# DON'T remove volumes - database data will persist
# docker volume ls -q | xargs docker volume rm 2>/dev/null || true
```
