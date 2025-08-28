#!/bin/bash
# View logs for Keycloak Authentication System

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default to all services
SERVICE="${1:-}"

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

show_usage() {
    echo "Usage: ./logs.sh [service] [options]"
    echo ""
    echo "Services:"
    echo "  keycloak    - Show Keycloak logs"
    echo "  db          - Show PostgreSQL logs"
    echo "  nginx       - Show Nginx logs"
    echo "  all         - Show all service logs (default)"
    echo ""
    echo "Options:"
    echo "  -f, --follow    - Follow log output"
    echo "  -n, --tail      - Number of lines to show from the end (default: 100)"
    echo ""
    echo "Examples:"
    echo "  ./logs.sh                    # Show all logs"
    echo "  ./logs.sh keycloak           # Show only Keycloak logs"
    echo "  ./logs.sh keycloak -f        # Follow Keycloak logs"
    echo "  ./logs.sh all -f             # Follow all logs"
    echo "  ./logs.sh nginx -n 50        # Show last 50 lines of Nginx logs"
}

# Parse arguments
FOLLOW=""
TAIL="100"
COMPOSE_SERVICE=""

case "$1" in
    keycloak)
        COMPOSE_SERVICE="keycloak"
        shift
        ;;
    db)
        COMPOSE_SERVICE="db"
        shift
        ;;
    nginx)
        COMPOSE_SERVICE="nginx"
        shift
        ;;
    all|"")
        COMPOSE_SERVICE=""
        shift
        ;;
    -h|--help)
        show_usage
        exit 0
        ;;
    *)
        if [[ "$1" == -* ]]; then
            # It's an option, not a service
            COMPOSE_SERVICE=""
        else
            echo -e "${RED}Error: Unknown service '$1'${NC}"
            echo ""
            show_usage
            exit 1
        fi
        ;;
esac

# Parse remaining options
while [[ $# -gt 0 ]]; do
    case "$1" in
        -f|--follow)
            FOLLOW="-f"
            shift
            ;;
        -n|--tail)
            TAIL="$2"
            shift 2
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
done

# Show logs
if [ -z "$COMPOSE_SERVICE" ]; then
    echo -e "${BLUE}Showing logs for all services...${NC}"
    docker compose -f docker-compose.prod.yml --env-file .env logs --tail="$TAIL" $FOLLOW
else
    echo -e "${BLUE}Showing logs for $COMPOSE_SERVICE...${NC}"
    docker compose -f docker-compose.prod.yml --env-file .env logs --tail="$TAIL" $FOLLOW $COMPOSE_SERVICE
fi
