#!/bin/bash

set -e

[[ "$SET_X" == "true" ]] && set -x

function log() {
    echo "$(date +%Y%m%dT%H%M%S) - $1"
}

for VAR in TEMP_DIR \
           TAR_FILE_HEADER \
           PGHOST \
           PGDATABASE \
           PGUSER \
           PGPASSWORD \
           S3_BUCKET_NAME \
           AWS_ACCESS_KEY_ID \
           AWS_SECRET_ACCESS_KEY \
           AWS_DEFAULT_REGION
do
    if [[ ! "${!VAR}" ]]; then
        echo "${VAR} not defined"
        COUNT=$((COUNT + 1))
    fi
done

[[ $COUNT -gt 0 ]] && exit 1

QUERY_DIR=/postgres-diag-queries
TIMESTAMP=$(date +%Y%m%dT%H%M%S)

log "Starting."

TAR_DIR_BASENAME="queries-${TAR_FILE_HEADER}-${TIMESTAMP}"
TAR_ABS_DIR="$TEMP_DIR/$TAR_DIR_BASENAME"
mkdir "$TAR_ABS_DIR"
for QUERY_FILE in "$QUERY_DIR"/*.sql; do
    BASENAME=$(basename "$QUERY_FILE")
    log "Running query on ${QUERY_FILE}."
    psql --file="$QUERY_FILE" --csv --output="$TAR_ABS_DIR/$BASENAME.out"
done

TAR_FILE="$TEMP_DIR/$TAR_DIR_BASENAME.tar.gz"
log "Creating tar file $TAR_FILE."
cd "$TEMP_DIR"
tar cvzf "$TAR_FILE" "$TAR_DIR_BASENAME"

log "Copying $TAR_FILE to S3."
aws s3 cp "$TAR_FILE" "s3://$S3_BUCKET_NAME"

log "Done"
