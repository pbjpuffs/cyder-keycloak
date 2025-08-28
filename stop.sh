#!/bin/bash
# Stop Keycloak Authentication System

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Stopping Keycloak Authentication System...${NC}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

# Stop all services
docker compose -f docker-compose.prod.yml --env-file .env down

echo -e "${GREEN}Keycloak system stopped successfully!${NC}"
echo ""
echo "Note: Database volumes are preserved."
echo "To completely remove all data, run:"
echo "  docker compose -f docker-compose.prod.yml --env-file .env down -v"
