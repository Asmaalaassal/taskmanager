# CI/CD Deployment Guide

**⚠️ For first-time setup, use [QUICK_START.md](./QUICK_START.md) instead!**

This is a comprehensive reference guide with detailed information, troubleshooting, and advanced topics. The deployment is **fully automated** - see QUICK_START.md for the simple steps.

## 🚀 Quick Start

### 1. Initial Server Setup

SSH into your VPS and run:

```bash
ssh root@147.79.101.138
cd /opt
git clone <your-github-repo-url> ticket-manager
cd ticket-manager
chmod +x scripts/*.sh
./scripts/first-time-setup.sh
```

### 2. Configure GitHub Secrets

**Note:** Only server credentials are needed! All other secrets (JWT, MySQL passwords) are **auto-generated**.

Go to your GitHub repository → Settings → Secrets and variables → Actions

Add these secrets:

#### Test Environment
- `TEST_SERVER_HOST`: `147.79.101.138`
- `TEST_SERVER_USER`: `root`
- `TEST_SERVER_PASSWORD`: `Zakia-3315Zw`

#### Production Environment
- `PROD_SERVER_HOST`: `147.79.101.138`
- `PROD_SERVER_USER`: `root`
- `PROD_SERVER_PASSWORD`: `Zakia-3315Zw`

**That's it!** Environment files and all other secrets are created automatically on first deployment.

### 3. Deploy (Fully Automated)

## 📋 Deployment Workflows

### Test Deployment (Automatic)

1. **Push to `develop` or `test` branch**
2. GitHub Actions automatically:
   - Builds Docker images
   - Pushes to GitHub Container Registry
   - Deploys to test environment
   - Runs health checks

**Test Environment Access:**
- Frontend: http://147.79.101.138:5174
- Backend API: http://147.79.101.138:8086/api
- MySQL: Port 3307

### Production Deployment (Manual Approval)

1. **Merge code to `main` branch**
2. Go to **Actions** tab in GitHub
3. Select **"Deploy to Production"** workflow
4. Click **"Run workflow"**
5. Type **"deploy"** in the confirmation field
6. Click **"Run workflow"**

The workflow will:
- ✅ Validate confirmation
- ✅ Build production images
- ✅ **Backup production database** (automatic)
- ✅ Deploy to production
- ✅ Run health checks
- ✅ Create deployment tag

**Production Environment Access:**
- Frontend: http://147.79.101.138 (Port 80)
- Backend API: http://147.79.101.138:8085/api
- MySQL: Port 3306

## 💾 Database Backups

### Automatic Backups
- Created automatically before each production deployment
- Stored in `/opt/ticket-manager/backups/`
- Keeps last 30 days of backups
- Compressed as `.sql.gz` files

### Manual Backup
```bash
cd /opt/ticket-manager
./scripts/backup-database.sh prod
```

### Restore Backup
```bash
cd /opt/ticket-manager
./scripts/restore-database.sh prod backups/backup_prod_20241216_143000.sql.gz
```

## 🔍 Monitoring & Management

### Check Container Status
```bash
# Test environment
docker-compose -f docker-compose.test.yml ps

# Production environment
docker-compose -f docker-compose.prod.yml ps
```

### View Logs
```bash
# All services
docker-compose -f docker-compose.prod.yml logs -f

# Specific service
docker-compose -f docker-compose.prod.yml logs -f backend-prod
docker-compose -f docker-compose.prod.yml logs -f frontend-prod
docker-compose -f docker-compose.prod.yml logs -f mysql-prod
```

### Health Checks
```bash
# Backend
curl http://localhost:8085/api/auth/me

# Frontend
curl http://localhost/
```

### Restart Services
```bash
docker-compose -f docker-compose.prod.yml restart
```

## 🛠️ Troubleshooting

### Containers won't start
```bash
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d
```

### Database connection issues
```bash
# Check MySQL container
docker-compose -f docker-compose.prod.yml exec mysql-prod mysql -u root -p

# Check database exists
docker-compose -f docker-compose.prod.yml exec mysql-prod mysql -u root -p -e "SHOW DATABASES;"
```

### Clear everything and start fresh
```bash
# ⚠️ WARNING: This deletes all data!
docker-compose -f docker-compose.prod.yml down -v
docker-compose -f docker-compose.prod.yml up -d --build
```

### Check disk space
```bash
df -h
docker system df
```

### Clean up old images
```bash
docker image prune -a
```

## 📁 Directory Structure

```
/opt/ticket-manager/
├── backend/
├── frontend/
├── scripts/
│   ├── backup-database.sh
│   ├── restore-database.sh
│   ├── first-time-setup.sh
│   ├── auto-setup.sh
│   └── auto-deploy.sh
├── backups/          # Database backups
├── ssl/              # SSL certificates (if using HTTPS)
├── docker-compose.test.yml
├── docker-compose.prod.yml
├── .env.test
└── .env.prod
```

## 🔐 Security Best Practices

1. **Change default passwords** in production `.env.prod`
2. **Use strong JWT secrets** (minimum 32 characters)
3. **Restrict SSH access** to specific IPs
4. **Enable firewall** (UFW) on VPS
5. **Regular backups** (automatic + manual)
6. **Monitor logs** for suspicious activity
7. **Keep Docker images updated**

## 📝 Notes

- Test and production environments run **separately** on different ports
- Database data is **persisted** in Docker volumes
- Backups are **automatically created** before production deployments
- Images are stored in **GitHub Container Registry** (ghcr.io)
- All deployments are **logged** in GitHub Actions

## 🆘 Support

If you encounter issues:
1. Check GitHub Actions logs
2. Check container logs on server
3. Verify environment variables
4. Check database connectivity
5. Review deployment documentation
