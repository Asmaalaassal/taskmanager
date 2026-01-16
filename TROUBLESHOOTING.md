# Troubleshooting Guide

## Git Clone Authentication Issues

### Problem: "Password authentication is not supported"

GitHub no longer accepts passwords for Git operations. Use one of these solutions:

### Solution 1: Use SSH (Recommended)

If you have SSH keys set up with GitHub:

```bash
git clone git@github.com:Asmaalaassal/taskmanager.git ticket-manager
```

### Solution 2: Use Personal Access Token (PAT)

1. **Create a Personal Access Token:**
   - Go to GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
   - Click "Generate new token (classic)"
   - Give it a name (e.g., "VPS Deployment")
   - Select scopes: `repo` (full control of private repositories)
   - Click "Generate token"
   - **Copy the token immediately** (you won't see it again!)

2. **Use the token as password:**
   ```bash
   git clone https://github.com/Asmaalaassal/taskmanager.git ticket-manager
   # Username: Asmaalaassal
   # Password: <paste your token here>
   ```

### Solution 3: Clone Public Repo (If repository is public)

If your repository is public, you can clone without authentication:

```bash
git clone https://github.com/Asmaalaassal/taskmanager.git ticket-manager
```

### Solution 4: Use GitHub CLI

```bash
# Install GitHub CLI
apt-get install -y gh

# Authenticate
gh auth login

# Clone
gh repo clone Asmaalaassal/taskmanager ticket-manager
```

## After Cloning

Once you've cloned the repository, continue with QUICK_START.md:

```bash
cd ticket-manager
chmod +x scripts/*.sh
./scripts/first-time-setup.sh
```
