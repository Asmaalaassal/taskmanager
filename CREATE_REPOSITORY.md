# Creating GitHub Repository

If the repository `https://github.com/Asmaalaassal/taskmanager` doesn't exist yet, create it:

## Option 1: Create via GitHub Web Interface

1. Go to https://github.com/new
2. Repository name: `taskmanager`
3. Choose visibility (Public or Private)
4. **Do NOT** initialize with README, .gitignore, or license (we already have these)
5. Click "Create repository"

## Option 2: Create via GitHub CLI

```bash
# Install GitHub CLI if not installed
# On Windows: winget install GitHub.cli
# On Linux/Mac: brew install gh or apt install gh

# Login
gh auth login

# Create repository
gh repo create Asmaalaassal/taskmanager --private --source=. --remote=origin --push
```

## After Creating

Once the repository exists, you can push:

```bash
git push -u origin master
# or
git push -u origin main
```
