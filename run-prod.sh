#!/bin/bash

# Excalidraw Production Stack Runner
# This script starts the full Excalidraw stack for production.

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Excalidraw Production Stack...${NC}"

echo -e "${BLUE}Updating source code from Git...${NC}"
git pull

# Check for .env.production.local
if [ ! -f .env.production.local ]; then
  echo -e "${RED}Error: .env.production.local not found!${NC}"
  echo -e "${YELLOW}Please create .env.production.local and add your TUNNEL_TOKEN:${NC}"
  echo "TUNNEL_TOKEN=your_token_here"
  exit 1
fi

# Build and start services
# We use --env-file to load the secrets from the local file
docker compose -f docker-compose.full.yml --env-file .env.production.local up --build -d

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Excalidraw production stack is starting up!${NC}"
  echo -e "${BLUE}Use 'docker compose -f docker-compose.full.yml ps' to check status.${NC}"
else
  echo -e "${RED}Failed to start the production stack. Please check the logs.${NC}"
  exit 1
fi
