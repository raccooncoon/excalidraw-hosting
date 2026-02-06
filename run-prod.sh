#!/bin/bash

# Excalidraw Production Stack Runner (Remote Version)
# This script only starts the containers. Build is done locally.

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Excalidraw Production Stack on Remote Server...${NC}"

# Check for .env.production.local
if [ ! -f .env.production.local ]; then
  echo -e "${RED}Error: .env.production.local not found!${NC}"
  echo -e "${YELLOW}Please ensure .env.production.local exists on the server with your TUNNEL_TOKEN.${NC}"
  exit 1
fi

# Build and start services
echo -e "${BLUE}Starting Docker containers...${NC}"
docker compose -f docker-compose.full.yml --env-file .env.production.local up --build -d

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Excalidraw production stack is running!${NC}"
else
  echo -e "${RED}Failed to start the production stack.${NC}"
  exit 1
fi
