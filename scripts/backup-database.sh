#!/bin/bash

# Database backup script
# Usage: ./backup-database.sh [test|prod]

ENVIRONMENT=${1:-prod}
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/ticket-manager/backups"
CONTAINER_NAME="ticket-mysql-${ENVIRONMENT}"
DB_NAME="ticket_system"
if [ "$ENVIRONMENT" = "test" ]; then
    DB_NAME="ticket_system_test"
fi

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Backup database
BACKUP_FILE="${BACKUP_DIR}/backup_${ENVIRONMENT}_${TIMESTAMP}.sql"

echo "Creating backup: $BACKUP_FILE"

docker exec "$CONTAINER_NAME" mysqldump \
    -u root \
    -p"${MYSQL_ROOT_PASSWORD}" \
    --single-transaction \
    --routines \
    --triggers \
    "$DB_NAME" > "$BACKUP_FILE"

if [ $? -eq 0 ]; then
    echo "Backup created successfully: $BACKUP_FILE"
    
    # Compress backup
    gzip "$BACKUP_FILE"
    echo "Backup compressed: ${BACKUP_FILE}.gz"
    
    # Keep only last 30 days of backups
    find "$BACKUP_DIR" -name "backup_${ENVIRONMENT}_*.sql.gz" -mtime +30 -delete
    echo "Old backups cleaned up"
else
    echo "Backup failed!"
    exit 1
fi
