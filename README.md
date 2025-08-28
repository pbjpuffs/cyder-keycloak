## Keycloak with Docker Compose (Dev and Production)

This repo provides a ready-to-run Keycloak setup for development and production. Production runs behind Nginx using a Cloudflare Origin Certificate for SSL/TLS with Cloudflare set to Full (strict).

### Prerequisites
- Docker and Docker Compose
- A domain proxied by Cloudflare
- Cloudflare SSL/TLS mode set to Full (strict)

### Environment configuration
Copy `env.example` to `.env` and adjust values:

```
cp env.example .env
```

Set `KC_HOSTNAME` to your public domain (e.g. `auth.example.com`).

### Quick Start - Management Scripts

The following scripts are provided for easy system management:

- `./start.sh` - Start the production system (handles first-run setup automatically)
- `./stop.sh` - Stop all services gracefully
- `./restart.sh` - Restart all services
- `./status.sh` - Check system status and health
- `./logs.sh [service] [-f]` - View logs (all, keycloak, db, or nginx)
- `./start-dev.sh` - Start development environment
- `./build-optimized.sh` - Build an optimized Keycloak image for faster startups

**Note:** On Windows, run these scripts using Git Bash, WSL, or prefix with `bash`.

### Development
- Runs Keycloak + Postgres only
- Access: `http://localhost:8080`

Start:

```
docker compose -f docker-compose.dev.yml up -d
```

Stop:

```
docker compose -f docker-compose.dev.yml down
```

### Production (Cloudflare Full strict)
Architecture: Cloudflare ➜ Nginx (TLS termination with origin cert) ➜ Keycloak (HTTP) ➜ Postgres.

1) Generate a Cloudflare Origin Certificate for your domain in the Cloudflare dashboard and download the certificate and private key.
2) Place files on the host:
   - Certificate: `nginx/certs/origin-cert.pem`
   - Private key: `nginx/certs/origin-key.pem`
3) Ensure `.env` has your `KC_HOSTNAME` set to the public domain (proxied by Cloudflare). Example: `KC_HOSTNAME=auth.example.com`.
4) First run only: the Keycloak image should start without the `--optimized` flag (already configured). If you later customize the config and want pre-optimized startup, build the server inside the container using `kc.sh build` and then you can use `--optimized`.

5) Start services:

```
docker compose -f docker-compose.prod.yml up -d
```

Access Keycloak at `https://<KC_HOSTNAME>` via Cloudflare.

Stop:

```
docker compose -f docker-compose.prod.yml down
```

### Notes
- Nginx is configured with `X-Forwarded-*` headers; Keycloak uses `KC_PROXY_HEADERS=xforwarded` for proper proxy handling.
- Keycloak 26 uses new hostname v2 configuration with `KC_HOSTNAME_STRICT=true` for security.
- Environment variables use new names: `KC_BOOTSTRAP_ADMIN_USERNAME` and `KC_BOOTSTRAP_ADMIN_PASSWORD`.
- Ensure your Cloudflare DNS record for `KC_HOSTNAME` is proxied (orange cloud).
- If you rotate the origin cert, replace the files and reload Nginx by restarting the container.


