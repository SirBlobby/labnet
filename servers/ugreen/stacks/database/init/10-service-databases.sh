#!/usr/bin/env bash
set -e

IFS=',' read -ra database_names <<< "${SERVICE_DATABASES:-}"

for database_name in "${database_names[@]}"; do
    database_name="$(echo "$database_name" | tr -d '[:space:]')"
    if [[ -z "$database_name" ]]; then
        continue
    fi

    password_variable="${database_name^^}_DB_PASSWORD"
    database_password="${!password_variable:-}"

    if [[ -z "$database_password" ]]; then
        echo "Skipping $database_name: $password_variable is not set"
        continue
    fi

    psql -v ON_ERROR_STOP=1 --username "${POSTGRES_USER:-postgres}" --dbname postgres \
        -v name="$database_name" -v password="$database_password" <<'SQL'
SELECT format('CREATE ROLE %I LOGIN PASSWORD %L', :'name', :'password')
WHERE NOT EXISTS (SELECT FROM pg_roles WHERE rolname = :'name')\gexec
SELECT format('ALTER ROLE %I WITH LOGIN PASSWORD %L', :'name', :'password')\gexec
SELECT format('CREATE DATABASE %I OWNER %I', :'name', :'name')
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = :'name')\gexec
SQL

    echo "Database ready: $database_name"
done
