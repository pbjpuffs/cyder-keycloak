#!/bin/bash
# Build optimized Keycloak image

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}Building optimized Keycloak image...${NC}"
echo "This will create a pre-built image for faster startup times."
echo ""

# Check if .env file exists
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy env.example to .env and configure it:"
    echo "  cp env.example .env"
    exit 1
fi

# Get Keycloak version from env
KC_VERSION=$(grep -E "^KC_VERSION=" .env | cut -d= -f2 || echo "26.0")

echo -e "${YELLOW}Using Keycloak version: $KC_VERSION${NC}"

# Check if system is running
if docker compose -f docker-compose.prod.yml --env-file .env ps | grep -q "keycloak.*Up"; then
    echo -e "${RED}Error: Keycloak is currently running!${NC}"
    echo "Please stop the system first with './stop.sh'"
    exit 1
fi

echo -e "${YELLOW}Step 1: Running build process...${NC}"
# Run the build in a temporary container with the same environment
docker compose -f docker-compose.prod.yml --env-file .env run \
    --rm \
    --no-deps \
    --name keycloak-builder \
    --entrypoint "/opt/keycloak/bin/kc.sh" \
    keycloak build

echo -e "${YELLOW}Step 2: Creating optimized image...${NC}"
# Create a Dockerfile for the optimized image
cat > Dockerfile.optimized <<EOF
FROM quay.io/keycloak/keycloak:${KC_VERSION}

# Copy the build from the builder stage
COPY --from=keycloak-builder /opt/keycloak /opt/keycloak

# Set the default command to start with optimization
CMD ["start", "--optimized"]
EOF

# Build the optimized image
docker build -f Dockerfile.optimized -t cyder/keycloak:${KC_VERSION}-optimized .

# Clean up
rm -f Dockerfile.optimized

echo -e "${GREEN}Optimized image built successfully!${NC}"
echo ""
echo "Image name: cyder/keycloak:${KC_VERSION}-optimized"
echo ""
echo "To use this image, update docker-compose.prod.yml:"
echo "  image: cyder/keycloak:${KC_VERSION}-optimized"
echo ""
echo "Then restart the system with './start.sh'"
