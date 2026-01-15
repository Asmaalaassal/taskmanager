#!/bin/bash

# Fix broken package installation issues
# Run this if you get dpkg errors during setup

set -e

echo "Fixing broken package states..."

# Configure all packages
echo "Configuring packages..."
dpkg --configure -a

# Fix broken dependencies
echo "Fixing broken dependencies..."
apt-get install -f -y

# Clean up
echo "Cleaning up..."
apt-get autoremove -y
apt-get autoclean

echo "✅ Package issues fixed!"
echo "You can now run ./scripts/first-time-setup.sh again"
