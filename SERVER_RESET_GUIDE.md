# Server Repository Reset Guide

## ⚠️ Important: What to Preserve

Before deleting the repository, you need to preserve:

1. **Environment files** (`.env.test` and `.env.prod`) - Contains database passwords and JWT secrets
2. **Database data** - Stored in Docker volumes (will persist automatically)
3. **Backups** - If you have any in `/opt/ticket-manager/backups`

## Step-by-Step Instructions

### Option 1: Preserve Environment Files (Recommended)

If you want to keep your existing database credentials:

```bash
# SSH to your server
ssh root@147.79.101.138

# Backup environment files
mkdir -p /opt/backup-env
cp /opt/ticket-manager/.env.test /opt/backup-env/.env.test 2>/dev/null || true
cp /opt/ticket-manager/.env.prod /opt/backup-env/.env.prod 2>/dev/null || true

# Stop all containers
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml down 2>/dev/null || true
docker compose -f docker-compose.prod.yml down 2>/dev/null || true

# Delete the repository
cd /opt
rm -rf ticket-manager

# Clone fresh repository
git clone https://github.com/hassanlagmouri/spring_taskmanager.git ticket-manager
cd ticket-manager

# Restore environment files
cp /opt/backup-env/.env.test /opt/ticket-manager/.env.test 2>/dev/null || true
cp /opt/backup-env/.env.prod /opt/ticket-manager/.env.prod 2>/dev/null || true

# Set permissions
chmod 600 /opt/ticket-manager/.env.* 2>/dev/null || true
chmod +x /opt/ticket-manager/scripts/*.sh

# Verify script is correct
head -40 scripts/auto-deploy.sh | grep "Preparing for local build" && echo "✅ Script is correct" || echo "❌ Script check failed"

echo "✅ Repository reset complete!"
```

### Option 2: Fresh Start (New Credentials)

If you want to start fresh with new credentials:

```bash
# SSH to your server
ssh root@147.79.101.138

# Stop all containers
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml down 2>/dev/null || true
docker compose -f docker-compose.prod.yml down 2>/dev/null || true

# Delete the repository
cd /opt
rm -rf ticket-manager

# Clone fresh repository
git clone https://github.com/hassanlagmouri/spring_taskmanager.git ticket-manager
cd ticket-manager

# Set permissions
chmod +x scripts/*.sh

# Verify script is correct
head -40 scripts/auto-deploy.sh | grep "Preparing for local build" && echo "✅ Script is correct" || echo "❌ Script check failed"

# Run setup (will create new .env files with new credentials)
export GITHUB_REPOSITORY=hassanlagmouri/spring_taskmanager
./scripts/auto-setup.sh test

echo "✅ Repository reset complete!"
echo "⚠️  Note: Database will need to be reset or migrated with new credentials"
```

## After Reset

### If you preserved .env files:
- Database will work with existing credentials
- No data loss
- Just run: `./scripts/auto-deploy.sh test`

### If you created new .env files:
- Database volumes still exist but with old credentials
- You have two options:
  1. **Reset database** (lose data):
     ```bash
     docker volume rm ticket-manager_mysql-test-data 2>/dev/null || true
     docker volume rm ticket-manager_mysql-prod-data 2>/dev/null || true
     ```
  2. **Update MySQL password** (keep data):
     - Connect to MySQL container
     - Update root password to match new .env file
     - This is more complex, so resetting is easier for test environment

## Verify Everything Works

After reset, test the deployment:

```bash
cd /opt/ticket-manager
export GITHUB_REPOSITORY=hassanlagmouri/spring_taskmanager
./scripts/auto-deploy.sh test
```

You should see:
- ✅ "Step 3: Preparing for local build..." (NOT "Checking Docker images...")
- ✅ "Building backend image (local build, no pull)..."
- ✅ No authentication prompts
- ✅ Services start successfully

## Next Steps

After manual reset, future deployments via GitHub Actions will work automatically because:
- The workflow now forces hard reset
- Script version is verified
- No more pull attempts
