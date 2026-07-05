#!/bin/bash

set -e

ROLLBACK_TAG=$1
HOST=$2
PORT=$3
DB=$4
USER=$5

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$ROOT_DIR"

echo "===================================="
echo "Rollback Tag : $ROLLBACK_TAG"
echo "===================================="

git fetch --all --tags

echo "Available Tags:"
git tag

# Check whether the rollback tag exists
if ! git rev-parse --verify "refs/tags/$ROLLBACK_TAG" >/dev/null 2>&1; then
    echo "ERROR: Tag '$ROLLBACK_TAG' not found."
    exit 1
fi

echo "Finding versioned migrations to rollback..."

FILES=$(git diff --name-only "refs/tags/$ROLLBACK_TAG"..HEAD -- database/schema \
    | grep "^database/schema/V.*\.sql$" \
    | sort -Vr || true)

if [ -z "$FILES" ]; then
    echo "No versioned migrations to rollback."
    exit 0
fi

echo "Versioned migrations found:"
echo "$FILES"

for file in $FILES
do
    FILE_NAME=$(basename "$file")

    VERSION=$(echo "$FILE_NAME" | sed -E 's/^V([0-9]+).*/\1/')

    UNDO_FILE=$(find "$ROOT_DIR/database/undo" -name "U${VERSION}__*.sql")

    if [ -z "$UNDO_FILE" ]; then
        echo "ERROR: Undo script not found for version $VERSION"
        exit 1
    fi

    echo "Executing: $UNDO_FILE"

    PGPASSWORD=$PGPASSWORD psql \
        -h "$HOST" \
        -p "$PORT" \
        -U "$USER" \
        -d "$DB" \
        -f "$UNDO_FILE"

done

echo "Rollback completed successfully."