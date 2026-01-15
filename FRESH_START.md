# Fresh Start Guide

This guide helps you clean the server and start fresh with the optimized deployment.

## 🧹 Server Cleanup

SSH into your server and run the cleanup script:

```bash
ssh root@147.79.101.138

# Download and run cleanup script (or copy from repo)
curl -o /tmp/cleanup.sh https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/CLEANUP_SERVER.sh
# OR copy the script manually

chmod +x /tmp/cleanup.sh
/tmp/cleanup.sh
```

**Or run manually:**

```bash
# Stop containers
docker compose -f /opt/ticket-manager/docker-compose.test.yml down 2>/dev/null || true
docker compose -f /opt/ticket-manager/docker-compose.prod.yml down 2>/dev/null || true

# Remove containers
docker ps -aq | xargs docker rm -f 2>/dev/null || true

# Remove images
docker images -q | xargs docker rmi -f 2>/dev/null || true

# Remove volumes (WARNING: deletes database data)
docker volume ls -q | xargs docker volume rm 2>/dev/null || true

# Remove repository
rm -rf /opt/ticket-manager

# Clean Docker
docker system prune -a -f --volumes
```

## 🚀 What's New

### Optimized Workflows
- ✅ Added test jobs (backend and frontend build validation)
- ✅ Removed Docker image building from workflows (build locally on server)
- ✅ Simplified deployment process
- ✅ Faster CI/CD pipeline

### What Changed
1. **GitHub Actions**: Tests run first, then deployment (if tests pass)
2. **Local Builds**: All images built directly on server (no registry needed)
3. **Cleaner Scripts**: Optimized auto-deploy script
4. **Removed Redundancy**: Consolidated documentation files

## 📋 After Cleanup

1. **Push your code to GitHub:**
   ```bash
   git add .
   git commit -m "Optimize workflows and cleanup"
   git push origin develop
   ```

2. **GitHub Actions will automatically:**
   - Run backend tests (build validation)
   - Run frontend tests (build validation)
   - Deploy to test server (if tests pass)
   - Clone repository fresh
   - Build images locally
   - Start services

3. **Monitor deployment:**
   - Go to GitHub → Actions tab
   - Watch the workflow progress
   - Check health check results

## ✅ Verify Deployment

After deployment, check:

```bash
# On server
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml ps

# Test backend
curl http://localhost:8086/api/auth/me

# From your machine
curl http://147.79.101.138:8086/api/auth/me
```

## 📝 Important Notes

- **Database data will be lost** if you delete volumes during cleanup
- All images are built locally on the server (no Docker Hub/GHCR needed)
- Tests must pass before deployment happens
- First deployment after cleanup may take longer (building images)
