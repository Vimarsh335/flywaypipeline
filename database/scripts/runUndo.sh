#!/bin/bash

ROLLBACK_TAG=$1
HOST=$2
PORT=$3
DB=$4
USER=$5

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo "Rollback Tag : $ROLLBACK_TAG"

cd "$ROOT_DIR"

git fetch --tags

echo "Finding versioned migrations to rollback..."

FILES=$(git diff --name-only "$ROLLBACK_TAG" HEAD -- database/schema | grep "database/schema/V.*\.sql$" | sort -Vr)

if [ -z "$FILES" ]; then
    echo "No versioned migrations to rollback."
    exit 0
fi

echo "$FILES"

for file in $FILES
do
    VERSION=$(basename "$file")

    VERSION=$(echo "$VERSION" | sed -E 's/^V([0-9]+).*/\1/')

    UNDO_FILE="$ROOT_DIR/database/undo/U${VERSION}__*.sql"

    FOUND=$(ls $UNDO_FILE 2>/dev/null)

    if [ -z "$FOUND" ]; then
        echo "Undo script not found for version $VERSION"
        exit 1
    fi

    echo "Executing $FOUND"

    PGPASSWORD=$PGPASSWORD psql \
        -h "$HOST" \
        -p "$PORT" \
        -U "$USER" \
        -d "$DB" \
        -f "$FOUND"

done