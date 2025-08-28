#!/bin/bash
# Start Keycloak Authentication System

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy env.example to .env and configure it:"
    echo "  cp env.example .env"
    exit 1
fi

# Determine if this is first run by checking if the database volume exists
if docker volume ls | grep -q "cyder-auth_db_data"; then
    FIRST_RUN=false
else
    FIRST_RUN=true
fi

echo -e "${GREEN}Starting Keycloak Authentication System...${NC}"

# For first run, we need to start without --optimized
if [ "$FIRST_RUN" = true ]; then
    echo -e "${YELLOW}First run detected. Starting without optimization...${NC}"
    # Temporarily modify the command
    sed -i.bak 's/\["start", "--optimized"\]/\["start"\]/' docker-compose.prod.yml
fi

# Start the system
docker compose -f docker-compose.prod.yml --env-file .env up -d

# If it was first run, wait for initialization then restore optimized setting
if [ "$FIRST_RUN" = true ]; then
    echo -e "${YELLOW}Waiting for initial setup to complete...${NC}"
    echo "This may take a few minutes on first run."
    
    # Wait for Keycloak to be ready by checking the health endpoint
    until docker exec keycloak curl -sf http://localhost:8080/health/ready >/dev/null 2>&1; do
        echo -n "."
        sleep 5
    done
    
    echo ""
    echo -e "${GREEN}Initial setup complete!${NC}"
    
    # Restore the optimized setting
    mv docker-compose.prod.yml.bak docker-compose.prod.yml
    
    echo -e "${YELLOW}Restarting with optimization enabled...${NC}"
    docker compose -f docker-compose.prod.yml --env-file .env restart keycloak
fi

echo -e "${GREEN}Keycloak system started successfully!${NC}"
echo ""
echo "Services:"
echo "  - Keycloak: https://$(grep KC_HOSTNAME .env | cut -d= -f2)"
echo "  - Database: PostgreSQL (internal)"
echo "  - Reverse Proxy: Nginx"
echo ""
echo "Use './logs.sh' to view logs"
echo "Use './stop.sh' to stop the system"
