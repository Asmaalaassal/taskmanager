#!/bin/bash

# Fix broken apt repositories
# Run this if you get repository errors during setup

set -e

echo "Fixing apt repository issues..."

# Remove or comment out the problematic monarx repository
if [ -f /etc/apt/sources.list.d/monarx.list ]; then
    echo "Removing problematic monarx repository..."
    rm /etc/apt/sources.list.d/monarx.list || mv /etc/apt/sources.list.d/monarx.list /etc/apt/sources.list.d/monarx.list.bak
fi

# Update apt sources
echo "Updating package lists..."
apt-get update

echo "✅ Repository issues fixed!"
