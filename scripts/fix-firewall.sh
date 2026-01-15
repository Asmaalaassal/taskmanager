#!/bin/bash

# Firewall Fix Script
# Opens required ports for the application

echo "=========================================="
echo "Firewall Configuration"
echo "=========================================="

# Check if UFW is installed and active
if command -v ufw &> /dev/null; then
    echo "UFW Status:"
    ufw status
    
    echo ""
    echo "Opening required ports..."
    
    # Allow SSH (important!)
    ufw allow 22/tcp
    
    # Test environment ports
    ufw allow 8086/tcp comment 'Backend API (Test)'
    ufw allow 5174/tcp comment 'Frontend (Test)'
    
    # Production ports
    ufw allow 8085/tcp comment 'Backend API (Prod)'
    ufw allow 80/tcp comment 'Frontend HTTP (Prod)'
    ufw allow 443/tcp comment 'Frontend HTTPS (Prod)'
    
    echo ""
    echo "✅ UFW rules added"
    echo ""
    echo "Current UFW status:"
    ufw status numbered
else
    echo "UFW not found. Checking iptables..."
    
    # Check iptables
    if command -v iptables &> /dev/null; then
        echo "Current iptables rules for port 8086:"
        iptables -L -n | grep 8086 || echo "No rules found for port 8086"
        
        echo ""
        echo "To allow port 8086, run as root:"
        echo "  iptables -A INPUT -p tcp --dport 8086 -j ACCEPT"
        echo "  iptables -A INPUT -p tcp --dport 5174 -j ACCEPT"
        echo "  iptables -A INPUT -p tcp --dport 8085 -j ACCEPT"
        echo "  iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
        echo "  iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
    fi
fi

echo ""
echo "=========================================="
echo "Verification"
echo "=========================================="
echo "Checking if ports are listening:"
netstat -tlnp 2>/dev/null | grep -E "8086|5174|8085|:80 " || ss -tlnp 2>/dev/null | grep -E "8086|5174|8085|:80 " || echo "No services listening on these ports"
