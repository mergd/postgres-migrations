#!/bin/bash



echo "Rye shell is active."

# Check if migra is installed
if ! command -v migra &> /dev/null; then
    echo "migra is not installed. Please install it using 'rye install migra' and try again."
    exit 1
fi

echo "migra is installed."

# Check if a name argument is provided
if [ $# -eq 0 ]; then
    echo "Please provide a name for the upgrade."
    exit 1
fi

# Set variables
UPGRADE_NAME=$1
TIMESTAMP=$(date +%s)
DB_NAME="temp_db"
DB_NAME_MIGRATED="${DB_NAME}_migrated"
DB_NAME_INIT="${DB_NAME}_init"
MIGRATIONS_FOLDER="./sql/migrations"
INIT_SQL="./sql/init.sql"
INIT_SNAPSHOT_SQL="./sql/init_snapshot.sql"

# Function to create a database
create_db() {
    psql -d postgres -c "CREATE DATABASE $1;"
}

# Function to drop a database
drop_db() {
    psql -d postgres -c "DROP DATABASE IF EXISTS $1;"
}

# Create the first database and apply migrations
create_db $DB_NAME_MIGRATED
psql -d $DB_NAME_MIGRATED -f $INIT_SNAPSHOT_SQL
for migration in $MIGRATIONS_FOLDER/*.up.sql; do
    psql -d $DB_NAME_MIGRATED -f $migration
done

# Create the second database and initialize from init.sql
create_db $DB_NAME_INIT
psql -d $DB_NAME_INIT -f $INIT_SQL

# Generate migration files
migra "postgresql:///$DB_NAME_INIT" "postgresql:///$DB_NAME_MIGRATED" --unsafe > "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.down.sql"
migra "postgresql:///$DB_NAME_MIGRATED" "postgresql:///$DB_NAME_INIT" --unsafe > "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.up.sql"

# Check if the generated files are empty
if [ ! -s "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.up.sql" ] && [ ! -s "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.down.sql" ]; then
    # Delete empty files
    rm "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.up.sql" "${MIGRATIONS_FOLDER}/${TIMESTAMP}_${UPGRADE_NAME}.down.sql"
    echo "No new changes detected. Empty migration files have been deleted."
else
    echo "Migration files generated:"
    echo "${TIMESTAMP}_${UPGRADE_NAME}.up.sql"
    echo "${TIMESTAMP}_${UPGRADE_NAME}.down.sql"
fi

# Clean up: drop the temporary databases
drop_db $DB_NAME_MIGRATED
drop_db $DB_NAME_INIT