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
- Nginx is configured with `X-Forwarded-*` headers; Keycloak runs with `KC_PROXY=edge` and strict HTTPS hostname enforcement.
- Ensure your Cloudflare DNS record for `KC_HOSTNAME` is proxied (orange cloud).
- If you rotate the origin cert, replace the files and reload Nginx by restarting the container.


