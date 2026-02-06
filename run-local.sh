#!/bin/bash

# Excalidraw Local Stack Runner
# This script starts the full Excalidraw stack (Frontend, Room, Storage) locally.

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Excalidraw Local Stack...${NC}"

# Check if .env.local exists, if so use it
if [ -f .env.local ]; then
  echo -e "${GREEN}Using .env.local for environment variables.${NC}"
  # We don't necessarily need to export them to the shell if Docker handles them, 
  # but docker-compose.local.yml uses build args.
fi

# Build and start services
docker compose -f docker-compose.local.yml up --build -d

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Excalidraw is running at http://localhost:8080${NC}"
  echo -e "${BLUE}To stop the stack, run: docker compose -f docker-compose.local.yml down${NC}"
else
  echo "Failed to start the local stack. Please check the logs."
  exit 1
fi
