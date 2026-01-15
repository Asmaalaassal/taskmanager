# 🤖 Fully Automated Deployment

This deployment system is **100% automated**. No manual configuration needed!

## ✨ What Gets Automated

- ✅ **Secret Generation** - All passwords and JWT secrets generated automatically
- ✅ **Environment Files** - Created automatically if they don't exist
- ✅ **Docker Images** - Pulled from registry, or built locally if not available
- ✅ **Database Setup** - Automatic initialization
- ✅ **Service Deployment** - Everything deployed automatically
- ✅ **Health Checks** - Automatic verification

## 🚀 Quick Start (One-Time Server Setup)

SSH into your VPS and run:

```bash
ssh root@147.79.101.138
# Password: Zakia-3315Zw

# Option 1: With repository URL (recommended)
curl -fsSL https://raw.githubusercontent.com/your-org/ticket-manager/main/scripts/first-time-setup.sh | bash -s -- https://github.com/your-org/ticket-manager.git

# Option 2: Manual
cd /opt
git clone https://github.com/your-org/ticket-manager.git ticket-manager
cd ticket-manager
chmod +x scripts/*.sh
./scripts/first-time-setup.sh
```

**That's it!** The server is now ready.

## 📋 GitHub Secrets (Minimal Required)

You only need to add these 3 secrets to GitHub:

```
TEST_SERVER_HOST=147.79.101.138
TEST_SERVER_USER=root
TEST_SERVER_PASSWORD=Zakia-3315Zw

PROD_SERVER_HOST=147.79.101.138
PROD_SERVER_USER=root
PROD_SERVER_PASSWORD=Zakia-3315Zw
```

**Everything else is generated automatically!**

## 🔄 How It Works

### Test Deployment (Automatic)

1. **Push to `develop` or `test` branch**
2. GitHub Actions:
   - Builds Docker images
   - Pushes to GitHub Container Registry
   - SSH to server
   - Runs `auto-setup.sh` (creates env file if needed)
   - Runs `auto-deploy.sh` (deploys everything)
3. **Done!** Your app is live

### Production Deployment (Manual)

1. **Merge to `main` branch**
2. Go to Actions → "Deploy to Production"
3. Type "deploy" to confirm
4. Same automated process runs
5. **Done!** Production is live

## 🔐 Auto-Generated Secrets

When environment files don't exist, the system automatically generates:

- **MySQL Root Password** - 64 character random hex
- **MySQL User Password** - 64 character random hex  
- **JWT Secret** - 64 character secure random string
- **All configuration** - Based on environment

**⚠️ Important:** Generated secrets are saved in `.env.test` and `.env.prod` files on the server. These files are protected (chmod 600).

## 🐳 Docker Image Strategy

The deployment is smart:

1. **First**: Tries to pull images from GitHub Container Registry
2. **If not found**: Builds images locally on the server
3. **Result**: Always works, even on first deployment!

## 📁 What Gets Created Automatically

```
/opt/ticket-manager/
├── .env.test          # Auto-generated (if missing)
├── .env.prod          # Auto-generated (if missing)
├── backups/           # Database backups
├── ssl/               # SSL certificates (if needed)
└── logs/              # Application logs
```

## 🔍 Manual Operations (Optional)

### View Generated Secrets

```bash
cat /opt/ticket-manager/.env.prod
```

### Regenerate Environment File

```bash
cd /opt/ticket-manager
rm .env.prod
./scripts/auto-setup.sh prod
```

### Manual Deployment

```bash
cd /opt/ticket-manager
./scripts/auto-deploy.sh prod
```

## 🎯 Deployment Flow

```
GitHub Push
    ↓
GitHub Actions Builds Images
    ↓
SSH to Server
    ↓
auto-setup.sh (if needed)
    ├─ Generate secrets
    ├─ Create .env file
    └─ Setup directories
    ↓
auto-deploy.sh
    ├─ Pull code
    ├─ Pull/build images
    ├─ Backup DB (prod only)
    ├─ Deploy services
    ├─ Health checks
    └─ Show status
    ↓
✅ Application Live!
```

## 🛡️ Security Notes

- Environment files are created with `chmod 600` (owner read/write only)
- Secrets are generated using OpenSSL (cryptographically secure)
- Database backups are created automatically before production deployments
- All sensitive data is stored securely on the server

## 🆘 Troubleshooting

### If deployment fails:

1. Check GitHub Actions logs
2. SSH to server and check:
   ```bash
   cd /opt/ticket-manager
   docker-compose -f docker-compose.prod.yml logs
   ```
3. Verify environment file exists:
   ```bash
   ls -la /opt/ticket-manager/.env.*
   ```

### Force rebuild:

```bash
cd /opt/ticket-manager
docker-compose -f docker-compose.prod.yml down
docker-compose -f docker-compose.prod.yml up -d --build
```

## 📝 Summary

**You don't need to:**
- ❌ Manually create environment files
- ❌ Generate secrets yourself
- ❌ Configure database passwords
- ❌ Build Docker images manually
- ❌ Set up anything on the server

**You just need to:**
- ✅ Run first-time setup once
- ✅ Add 3 GitHub secrets
- ✅ Push code to GitHub
- ✅ Everything else is automatic!
