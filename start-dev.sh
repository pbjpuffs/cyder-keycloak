#!/bin/bash
# Start Keycloak in development mode

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Starting Keycloak in Development Mode...${NC}"
echo "========================================"
echo ""

# Check if .env file exists (optional for dev)
if [ -f .env ]; then
    ENV_FILE="--env-file .env"
    echo -e "${GREEN}Using .env file for configuration${NC}"
else
    ENV_FILE=""
    echo -e "${YELLOW}No .env file found, using defaults from docker-compose.dev.yml${NC}"
fi

# Stop any running production instance
if docker compose -f docker-compose.prod.yml ps 2>/dev/null | grep -q "Up"; then
    echo -e "${YELLOW}Stopping production instance...${NC}"
    docker compose -f docker-compose.prod.yml down
fi

# Start development instance
echo -e "${GREEN}Starting development services...${NC}"
docker compose -f docker-compose.dev.yml $ENV_FILE up -d

echo ""
echo -e "${GREEN}Development system started successfully!${NC}"
echo ""
echo "Services:"
echo "  - Keycloak: http://localhost:8080"
echo "  - Admin Console: http://localhost:8080/admin"
echo "  - Default credentials: admin/admin"
echo ""
echo "Development features enabled:"
echo "  ✓ Hot reload"
echo "  ✓ Debug logging"
echo "  ✓ Direct access (no HTTPS/proxy)"
echo ""
echo "Commands:"
echo "  - View logs: docker compose -f docker-compose.dev.yml logs -f"
echo "  - Stop: docker compose -f docker-compose.dev.yml down"
echo "  - Restart: docker compose -f docker-compose.dev.yml restart"
