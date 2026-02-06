#!/bin/bash

# Excalidraw Local Stack Runner (Host Build Version)
# This script builds the app on the host and starts the containers.

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Excalidraw Local Stack (Host-side Build)...${NC}"

echo -e "${BLUE}Updating source code from Git...${NC}"
git pull

# Load .env.local if it exists
if [ -f .env.local ]; then
  echo -e "${GREEN}Using .env.local for build environment variables.${NC}"
  set -a
  source .env.local
  set +a
fi

echo -e "${BLUE}Installing dependencies on host...${NC}"
yarn install --network-timeout 600000

echo -e "${BLUE}Building application on host...${NC}"
yarn build:app

# Build and start services
echo -e "${BLUE}Starting Docker containers...${NC}"
docker compose -f docker-compose.local.yml up --build -d

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Excalidraw is running at http://localhost:8080${NC}"
  echo -e "${BLUE}To stop the stack, run: docker compose -f docker-compose.local.yml down${NC}"
else
  echo -e "${RED}Failed to start the local stack. Please check the logs.${NC}"
  exit 1
fi
