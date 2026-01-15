#!/bin/bash

# Server Diagnostic Script
# Run this on the server to diagnose connection issues

echo "=========================================="
echo "Server Diagnostic Script"
echo "=========================================="

# Check if repository exists
if [ ! -d /opt/ticket-manager ]; then
    echo "❌ Repository not found at /opt/ticket-manager"
    exit 1
fi

cd /opt/ticket-manager || exit 1

echo ""
echo "1. Container Status:"
echo "----------------------------------------"
docker compose -f docker-compose.test.yml ps

echo ""
echo "2. Backend Container Logs (last 30 lines):"
echo "----------------------------------------"
docker compose -f docker-compose.test.yml logs --tail=30 backend-test 2>/dev/null || echo "No logs found"

echo ""
echo "3. Port Binding Check:"
echo "----------------------------------------"
echo "Checking if port 8086 is bound:"
netstat -tlnp 2>/dev/null | grep 8086 || ss -tlnp 2>/dev/null | grep 8086 || echo "Port 8086 not found in netstat/ss"

echo ""
echo "4. Docker Port Mapping:"
echo "----------------------------------------"
docker port ticket-backend-test 2>/dev/null || echo "Container not running or port not mapped"

echo ""
echo "5. Backend Container Network:"
echo "----------------------------------------"
docker inspect ticket-backend-test 2>/dev/null | grep -A 10 "NetworkSettings" || echo "Container not found"

echo ""
echo "6. Testing from Server (localhost):"
echo "----------------------------------------"
curl -v http://localhost:8086/api/auth/me 2>&1 | head -20 || echo "❌ Connection failed from server"

echo ""
echo "7. Testing from Server (0.0.0.0):"
echo "----------------------------------------"
curl -v http://0.0.0.0:8086/api/auth/me 2>&1 | head -20 || echo "❌ Connection failed"

echo ""
echo "8. Firewall Status:"
echo "----------------------------------------"
if command -v ufw &> /dev/null; then
    ufw status | grep 8086 || echo "Port 8086 not explicitly allowed in UFW"
else
    echo "UFW not installed"
fi

echo ""
echo "9. iptables Rules (port 8086):"
echo "----------------------------------------"
iptables -L -n 2>/dev/null | grep 8086 || echo "No iptables rules found for port 8086"

echo ""
echo "10. Backend Process Check:"
echo "----------------------------------------"
docker exec ticket-backend-test ps aux 2>/dev/null | grep java || echo "Cannot check process (container may not be running)"

echo ""
echo "11. Network Connectivity:"
echo "----------------------------------------"
docker exec ticket-backend-test curl -s http://localhost:8085/api/auth/me 2>&1 | head -5 || echo "Cannot test from inside container"

echo ""
echo "=========================================="
echo "Diagnostic Complete"
echo "=========================================="
