# Troubleshooting Connection Timeout

If you're getting `ERR_CONNECTION_TIMED_OUT` when trying to access the backend, follow these steps:

## Quick Fix

**SSH into your server and run:**

```bash
ssh root@147.79.101.138

# 1. Check if containers are running
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml ps

# 2. Check if backend is listening
docker compose -f docker-compose.test.yml logs backend-test --tail=30

# 3. Test from server itself
curl -v http://localhost:8086/api/auth/me

# 4. Check firewall
sudo ufw status

# 5. If firewall is active, allow port 8086
sudo ufw allow 8086/tcp
sudo ufw allow 5174/tcp  # Frontend port
sudo ufw reload

# 6. Verify port is open
sudo ufw status | grep 8086
```

## Detailed Diagnosis

Run the diagnostic script:

```bash
cd /opt/ticket-manager
chmod +x scripts/diagnose-server.sh
./scripts/diagnose-server.sh
```

## Common Issues

### 1. Firewall Blocking Port

**Symptoms:** Connection timeout from outside, but works from server

**Fix:**
```bash
# UFW (Ubuntu Firewall)
sudo ufw allow 8086/tcp
sudo ufw allow 5174/tcp
sudo ufw reload

# Or use the fix script
cd /opt/ticket-manager
chmod +x scripts/fix-firewall.sh
sudo ./scripts/fix-firewall.sh
```

### 2. Container Not Running

**Symptoms:** No containers in `docker ps`

**Fix:**
```bash
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml up -d
docker compose -f docker-compose.test.yml ps
```

### 3. Backend Not Started

**Symptoms:** Container running but no response

**Fix:**
```bash
# Check logs
docker compose -f docker-compose.test.yml logs backend-test

# Restart
docker compose -f docker-compose.test.yml restart backend-test

# Check if Java process is running
docker exec ticket-backend-test ps aux | grep java
```

### 4. Port Not Bound

**Symptoms:** Container running but port not accessible

**Fix:**
```bash
# Check port binding
docker port ticket-backend-test

# Should show: 8086/tcp -> 0.0.0.0:8086

# Check if port is listening
netstat -tlnp | grep 8086
# OR
ss -tlnp | grep 8086
```

### 5. Network Configuration

**Symptoms:** Works locally but not from outside

**Check:**
```bash
# Verify Docker network
docker network inspect ticket-network-test

# Check container IP
docker inspect ticket-backend-test | grep IPAddress

# Test from inside container
docker exec ticket-backend-test curl http://localhost:8085/api/auth/me
```

## Step-by-Step Verification

1. **Container Status:**
   ```bash
   docker compose -f docker-compose.test.yml ps
   ```
   All services should show "Up"

2. **Backend Logs:**
   ```bash
   docker compose -f docker-compose.test.yml logs backend-test --tail=50
   ```
   Look for "Started TicketManagerApplication" and no errors

3. **Port Binding:**
   ```bash
   docker port ticket-backend-test
   ```
   Should show: `8086/tcp -> 0.0.0.0:8086`

4. **Local Test:**
   ```bash
   curl -v http://localhost:8086/api/auth/me
   ```
   Should return HTTP 403 (not 200, but server is responding)

5. **Firewall:**
   ```bash
   sudo ufw status
   ```
   Port 8086 should be listed as ALLOW

6. **External Test:**
   ```bash
   # From your local machine
   curl -v http://147.79.101.138:8086/api/auth/me
   ```
   Should return HTTP 403 (server responding)

## Still Not Working?

1. **Check server provider firewall:**
   - Some VPS providers have a firewall in their control panel
   - Check your hosting provider's firewall settings
   - Ensure port 8086 is open in their firewall

2. **Check Docker network:**
   ```bash
   docker network ls
   docker network inspect ticket-network-test
   ```

3. **Rebuild and redeploy:**
   ```bash
   cd /opt/ticket-manager
   docker compose -f docker-compose.test.yml down
   docker compose -f docker-compose.test.yml build --no-cache
   docker compose -f docker-compose.test.yml up -d
   ```

4. **Check system resources:**
   ```bash
   free -h
   df -h
   docker system df
   ```

## Quick Test Script

Run this on the server to test everything:

```bash
#!/bin/bash
echo "=== Container Status ==="
docker compose -f /opt/ticket-manager/docker-compose.test.yml ps

echo ""
echo "=== Backend Logs (last 10 lines) ==="
docker compose -f /opt/ticket-manager/docker-compose.test.yml logs --tail=10 backend-test

echo ""
echo "=== Port Check ==="
docker port ticket-backend-test 2>/dev/null || echo "Container not running"

echo ""
echo "=== Local Test ==="
curl -s -o /dev/null -w "HTTP Status: %{http_code}\n" http://localhost:8086/api/auth/me

echo ""
echo "=== Firewall Status ==="
sudo ufw status | grep 8086 || echo "Port 8086 not in UFW rules"
```
