#!/bin/bash
# Check status of Keycloak Authentication System

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Keycloak Authentication System Status${NC}"
echo "======================================"
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

# Check Docker daemon
if ! docker info >/dev/null 2>&1; then
    echo -e "${RED}Error: Docker daemon is not running!${NC}"
    exit 1
fi

# Get status
STATUS=$(docker compose -f docker-compose.prod.yml --env-file .env ps --format json 2>/dev/null || echo "[]")

if [ "$STATUS" == "[]" ] || [ -z "$STATUS" ]; then
    echo -e "${YELLOW}No services are running.${NC}"
    echo ""
    echo "Start the system with: ./start.sh"
    exit 0
fi

# Parse and display status
echo -e "${GREEN}Services Status:${NC}"
docker compose -f docker-compose.prod.yml --env-file .env ps

echo ""
echo -e "${GREEN}Resource Usage:${NC}"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" \
    $(docker compose -f docker-compose.prod.yml --env-file .env ps -q)

# Check Keycloak health if running
if docker compose -f docker-compose.prod.yml --env-file .env ps | grep -q "keycloak.*Up"; then
    echo ""
    echo -e "${GREEN}Keycloak Health Check:${NC}"
    if docker exec keycloak curl -s http://localhost:8080/health/ready | grep -q '"status":"UP"'; then
        echo "  ✓ Keycloak is healthy and ready"
    else
        echo "  ⚠ Keycloak is starting up..."
    fi
fi

# Show URLs
if docker compose -f docker-compose.prod.yml --env-file .env ps | grep -q "nginx.*Up"; then
    KC_HOSTNAME=$(grep -E "^KC_HOSTNAME=" .env | cut -d= -f2 || echo "localhost")
    echo ""
    echo -e "${GREEN}Access URLs:${NC}"
    echo "  - Keycloak: https://$KC_HOSTNAME"
    echo "  - Admin Console: https://$KC_HOSTNAME/admin"
fi
