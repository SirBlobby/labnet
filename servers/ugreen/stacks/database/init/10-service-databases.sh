#!/usr/bin/env bash
set -e

# One role and database for every <NAME>_DB_PASSWORD variable, plus any extra
# names in SERVICE_DATABASES. New .env.example keys reach an existing .env on
# update, so adding <NAME>_DB_PASSWORD is all a new service needs.
database_names=()
for variable in $(compgen -v | grep -E '^[A-Z0-9_]+_DB_PASSWORD$'); do
    database_names+=("$(printf '%s' "${variable%_DB_PASSWORD}" | tr '[:upper:]' '[:lower:]')")
done
IFS=',' read -ra listed_names <<< "${SERVICE_DATABASES:-}"
database_names+=("${listed_names[@]}")

for database_name in $(printf '%s\n' "${database_names[@]}" | tr -d '[:blank:]' | sort -u); do
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
