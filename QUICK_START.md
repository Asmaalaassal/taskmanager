# 🚀 Quick Start Guide

Get your Ticket Manager application deployed in 2 minutes - **100% Automated!**

## Step 1: One-Time Server Setup

SSH into your VPS and run:

```bash
ssh root@147.79.101.138
# Password: Zakia-3315Zw

cd /opt
# Use SSH if you have SSH keys set up:
# git clone git@github.com:Asmaalaassal/taskmanager.git ticket-manager
# OR use HTTPS with Personal Access Token (see TROUBLESHOOTING.md)
git clone https://github.com/Asmaalaassal/taskmanager.git ticket-manager
cd ticket-manager
chmod +x scripts/*.sh
./scripts/first-time-setup.sh
```

**That's it for server setup!** Everything else is automated.

## Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add these secrets:

### Required Secrets (Only 6!):

```
TEST_SERVER_HOST=147.79.101.138
TEST_SERVER_USER=root
TEST_SERVER_PASSWORD=Zakia-3315Zw

PROD_SERVER_HOST=147.79.101.138
PROD_SERVER_USER=root
PROD_SERVER_PASSWORD=Zakia-3315Zw
```

**All other secrets (JWT, MySQL passwords, etc.) are generated automatically!**

## Step 3: Deploy!

### Test Deployment (Automatic)
```bash
# Push to develop branch
git checkout -b develop
git push origin develop
```

GitHub Actions will automatically deploy to test environment!

### Production Deployment (Manual)
1. Merge to `main` branch
2. Go to Actions tab
3. Run "Deploy to Production" workflow
4. Type "deploy" to confirm

## 🎉 That's it!

- **Test:** http://147.79.101.138:5174
- **Production:** http://147.79.101.138

## ✨ What's Automated?

- ✅ **Secret Generation** - All passwords and keys generated automatically
- ✅ **Environment Files** - Created automatically on first deployment
- ✅ **Docker Images** - Pulled from registry or built locally
- ✅ **Database Setup** - Fully automatic
- ✅ **Deployment** - Everything handled automatically

## 📚 Need Help?

- See [AUTO_DEPLOYMENT.md](./AUTO_DEPLOYMENT.md) for full automation details
- See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed documentation
