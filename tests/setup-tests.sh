#! /bin/bash

# Color hints for alerts and messages
GREEN='\033[1;32m'
RED='\033[0;31m'
NC='\033[0m'

# Our tests need Docker installed
hash docker 2>/dev/null || { echo >&2 "I require Docker to be installed to run tests. Aborting."; exit 1; }

# Place to store container ID so tests can use it
CONTAINER_ID="${TMPDIR-/tmp}/travis_container_id"

# Clean up any stale test artifacts
docker rm -f melon

# Build the project
docker build -t cantaloupe .

# Run the project so it can be tested (will fail if docker-cantaloupe is already running)
docker run -d -p 8182:8182 -e "ENDPOINT_ADMIN_SECRET=secret" -e "ENDPOINT_ADMIN_ENABLED=true" --name melon -v testimages:/imageroot cantaloupe > "${CONTAINER_ID}"
