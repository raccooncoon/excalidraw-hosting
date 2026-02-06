#!/bin/bash

# Excalidraw Deployment Script (Run on Local Mac)
# Builds the application locally and syncs to Proxmox.

# --- Configuration ---
REMOTE_USER="root"
REMOTE_HOST="pve-nuc"
REMOTE_PATH="/opt/excalidraw"
# ---------------------

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Step 1: Updating local source code...${NC}"
git pull

echo -e "${BLUE}Step 2: Installing dependencies locally...${NC}"
yarn install --network-timeout 600000

echo -e "${BLUE}Step 3: Building application locally...${NC}"
yarn build:app

echo -e "${BLUE}Step 4: Syncing files to Proxmox ($REMOTE_HOST)...${NC}"
rsync -avz --delete \
  --exclude '.git' \
  --exclude 'node_modules' \
  --exclude '.env.production.local' \
  ./ $REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Sync complete!${NC}"
else
  echo -e "${RED}Sync failed. Please check SSH/rsync connection.${NC}"
  exit 1
fi

echo -e "${BLUE}Step 5: Restarting Docker containers on remote server...${NC}"
ssh $REMOTE_USER@$REMOTE_HOST "cd $REMOTE_PATH && chmod +x run-prod.sh && ./run-prod.sh"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Deployment Successful!${NC}"
else
  echo -e "${RED}Remote restart failed.${NC}"
  exit 1
fi
