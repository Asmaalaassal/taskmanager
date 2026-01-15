#!/bin/bash

# Database restore script
# Usage: ./restore-database.sh [test|prod] <backup_file>

ENVIRONMENT=${1:-prod}
BACKUP_FILE=${2}

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 [test|prod] <backup_file>"
    exit 1
fi

CONTAINER_NAME="ticket-mysql-${ENVIRONMENT}"
DB_NAME="ticket_system"
if [ "$ENVIRONMENT" = "test" ]; then
    DB_NAME="ticket_system_test"
fi

# Check if backup file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "Backup file not found: $BACKUP_FILE"
    exit 1
fi

# Decompress if needed
if [[ "$BACKUP_FILE" == *.gz ]]; then
    echo "Decompressing backup..."
    gunzip -c "$BACKUP_FILE" | docker exec -i "$CONTAINER_NAME" mysql \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        "$DB_NAME"
else
    docker exec -i "$CONTAINER_NAME" mysql \
        -u root \
        -p"${MYSQL_ROOT_PASSWORD}" \
        "$DB_NAME" < "$BACKUP_FILE"
fi

if [ $? -eq 0 ]; then
    echo "Database restored successfully from: $BACKUP_FILE"
else
    echo "Restore failed!"
    exit 1
fi
