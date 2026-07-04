#!/bin/bash

HOST=$1
PORT=$2
DB=$3
USER=$4

UNDO_FOLDER="database/undo"

for file in "$UNDO_FOLDER"/*.sql
do
    if [ ! -f "$file" ]; then
        echo "No undo scripts found."
        exit 0
    fi

    echo "Executing $file"

    PGPASSWORD=$PGPASSWORD psql \
        -h "$HOST" \
        -p "$PORT" \
        -U "$USER" \
        -d "$DB" \
        -f "$file"
done