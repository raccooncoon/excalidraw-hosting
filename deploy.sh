#!/bin/bash

# Excalidraw Deployment Script (Proxy Version via Proxmox Host)
# Builds locally, syncs to PVE Host, then pushes to LXC 1000.

# --- Configuration ---
PVE_HOST="pve-nuc"
LXC_ID="1000"
LXC_PATH="/opt/excalidraw"
TMP_HOST_PATH="/tmp/excalidraw_deploy"
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

echo -e "${BLUE}Step 4: Syncing files to Proxmox Host ($PVE_HOST)...${NC}"
rsync -avz --delete \
  --exclude '.git' \
  --exclude 'node_modules' \
  --exclude '.env.production.local' \
  ./ root@$PVE_HOST:$TMP_HOST_PATH

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Sync to Host complete!${NC}"
else
  echo -e "${RED}Sync to Host failed.${NC}"
  exit 1
fi

echo -e "${BLUE}Step 5: Pushing files to LXC $LXC_ID...${NC}"
ssh root@$PVE_HOST "cd $TMP_HOST_PATH && tar cf /tmp/excalidraw_deploy.tar . && pct push $LXC_ID /tmp/excalidraw_deploy.tar /tmp/excalidraw_deploy.tar && pct exec $LXC_ID -- mkdir -p $LXC_PATH && pct exec $LXC_ID -- tar xf /tmp/excalidraw_deploy.tar -C $LXC_PATH && rm /tmp/excalidraw_deploy.tar"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Push to LXC complete!${NC}"
else
  echo -e "${RED}Push to LXC failed.${NC}"
  exit 1
fi

echo -e "${BLUE}Step 6: Restarting Docker containers inside LXC $LXC_ID...${NC}"
ssh root@$PVE_HOST "pct exec $LXC_ID -- bash -c 'cd $LXC_PATH && chmod +x run-prod.sh && ./run-prod.sh'"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}Deployment Successful!${NC}"
else
  echo -e "${RED}Remote restart inside LXC failed.${NC}"
  exit 1
fi
