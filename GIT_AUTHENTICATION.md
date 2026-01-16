# Git Authentication Setup for GitHub Repository

## Problem
You're trying to push to `Asmaalaassal/taskmanager` but authenticated as `hassanlagmouri`.

## Solution 1: Use Personal Access Token (Recommended)

### Step 1: Create a Personal Access Token

1. Go to https://github.com/settings/tokens (as Asmaalaassal or as a collaborator)
2. Click "Generate new token (classic)"
3. Name: "Task Manager Deployment"
4. Scopes: Check `repo` (full control of private repositories)
5. Click "Generate token"
6. **Copy the token immediately** (you won't see it again!)

### Step 2: Update Git Remote with Token

**Option A: Use token in URL (one-time)**

```bash
git remote set-url origin https://YOUR_TOKEN@github.com/Asmaalaassal/taskmanager.git
git push origin master
```

**Option B: Use Git Credential Manager (recommended for Windows)**

```bash
# Git will prompt for credentials
git push origin master
# Username: Asmaalaassal
# Password: <paste your token here>
```

The credential manager will save it for future use.

**Option C: Use environment variable**

```bash
# Windows PowerShell
$env:GIT_ASKPASS = "echo"
git -c credential.helper="!f() { echo username=Asmaalaassal; echo password=YOUR_TOKEN; }; f" push origin master

# Windows CMD
set GIT_ASKPASS=echo
git -c credential.helper="!f() { echo username=Asmaalaassal; echo password=YOUR_TOKEN; }; f" push origin master
```

## Solution 2: Use SSH (if you have SSH keys)

```bash
# Change remote to use SSH
git remote set-url origin git@github.com:Asmaalaassal/taskmanager.git

# Push (will use SSH key)
git push origin master
```

**Note:** You need SSH keys set up for Asmaalaassal's account or have the repository added to your SSH agent.

## Solution 3: Get Collaborator Access

Ask Asmaalaassal to:
1. Go to repository Settings → Collaborators
2. Add `hassanlagmouri` as a collaborator
3. Then you can push with your own credentials

## Solution 4: Use Your Own Repository

If you want to use your own repository:

```bash
# Remove current remote
git remote remove origin

# Add your repository
git remote add origin https://github.com/hassanlagmouri/your-repo-name.git

# Push
git push -u origin master
```
