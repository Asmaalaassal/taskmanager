# Quick Fix: Connection Timeout

## Most Likely Issue: Firewall

**ERR_CONNECTION_TIMED_OUT** usually means the firewall is blocking port 8086.

## Immediate Fix (Run on Server)

```bash
ssh root@147.79.101.138

# Allow port 8086 in firewall
sudo ufw allow 8086/tcp
sudo ufw allow 5174/tcp
sudo ufw reload

# Verify
sudo ufw status | grep 8086
```

## Verify It's Working

```bash
# On server - test locally
curl http://localhost:8086/api/auth/me
# Should return HTTP 403 (server is responding)

# From your machine - test externally
curl http://147.79.101.138:8086/api/auth/me
# Should return HTTP 403 (server is responding)
```

## If Still Not Working

Run the diagnostic script:

```bash
cd /opt/ticket-manager
chmod +x scripts/diagnose-server.sh
./scripts/diagnose-server.sh
```

This will show:
- Container status
- Backend logs
- Port bindings
- Firewall status
- Network configuration

## Alternative: Use the Fix Script

```bash
cd /opt/ticket-manager
chmod +x scripts/fix-firewall.sh
sudo ./scripts/fix-firewall.sh
```

## Check Container Status

```bash
cd /opt/ticket-manager
docker compose -f docker-compose.test.yml ps
docker compose -f docker-compose.test.yml logs backend-test --tail=20
```

All containers should show "Up" status.
