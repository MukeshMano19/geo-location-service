#!/bin/sh

# Docker entrypoint script.
# Wait until Postgres is ready before running the next step.

while ! pg_isready -q -h $DATABASE_HOST -p $DATABASE_PORT -U $DATABASE_USER
do
  echo "$(date) - waiting for database to start."
  sleep 2
done

# Create Database, will skip if Database alrady exists.
mix ecto.create
  
# Runs migrations, will skip if migrations are up to date.
mix ecto.migrate

# Run Seeds.
mix run priv/repo/seeds.exs

# Start the server.
exec mix phx.server