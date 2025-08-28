#!/bin/bash
# Restart Keycloak Authentication System

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Restarting Keycloak Authentication System...${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

# Restart all services
docker compose -f docker-compose.prod.yml --env-file .env restart

echo -e "${GREEN}Keycloak system restarted successfully!${NC}"
echo ""
echo "Use './logs.sh' to view logs"
