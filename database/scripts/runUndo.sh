#!/bin/bash

HOST=$1
PORT=$2
DB=$3
USER=$4

UNDO_FOLDER=undo

for file in $(ls $UNDO_FOLDER/*.sql | sort -r)
do
    echo "Executing $file"

    PGPASSWORD=$PGPASSWORD psql \
        -h "$HOST" \
        -p "$PORT" \
        -U "$USER" \
        -d "$DB" \
        -f "$file"

done