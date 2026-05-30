# AGENTS.md

## Project Overview

This project deploys Piwigo photo gallery on Coolify using Docker Compose. It consists of three services: Piwigo (PHP-FPM + Nginx via supervisord), MariaDB, and a front-facing Nginx proxy.

## Architecture

```
piwigo-nginx (port 8080) -> piwigo (PHP-FPM on 127.0.0.1:9000) -> piwigo-db (MariaDB on port 3306)
```

### Services

- **piwigo-db**: MariaDB 11 with health checks
- **piwigo**: Custom image built from `php:8.3-fpm-alpine` with Piwigo, PHP-FPM, and Nginx managed by supervisord
- **piwigo-nginx**: Alpine Nginx as reverse proxy

### Key Files

| File | Purpose |
|------|---------|
| `docker-compose.yml` | Defines all services, networks, and volumes |
| `Dockerfile` | Builds the Piwigo application image |
| `supervisord.conf` | Manages PHP-FPM and Nginx processes in the Piwigo container |
| `nginx/default.conf` | Nginx site config for the proxy container |
| `nginx/nginx.conf` | Nginx main config for the proxy container |
| `nginx/php-fpm.conf` | PHP-FPM pool config (used inside Piwigo container) |
| `.env.example` | Template for environment variables |

## Environment Variables

All configuration is via `.env` file. Copy `.env.example` to `.env` and modify.

Required variables:
- `MYSQL_ROOT_PASSWORD` - MariaDB root password
- `MYSQL_PASSWORD` - Piwigo database user password

Optional variables:
- `TZ` - Timezone (default: UTC)
- `APP_PORT` - External port (default: 8080)
- `MYSQL_DATABASE` - Database name (default: piwigo)
- `MYSQL_USER` - Database user (default: piwigo)

## Piwigo Version

The Piwigo version is set in the `Dockerfile` via `PIWIGO_VERSION`. To update, change this value and rebuild.

## Persistent Data

Four named volumes store persistent data:
- `piwigo-db-data` - Database files
- `piwigo-gallery-data` - Gallery images (`_data/i`)
- `piwigo-local-data` - Local files (plugins, themes)
- `piwigo-upload-data` - Upload directory

## Coolify Deployment Notes

- Deploy as a "Docker Compose" resource in Coolify
- Set environment variables in Coolify's UI or via `.env`
- Coolify will handle SSL if a domain is configured
- The `piwigo-nginx` service exposes the application port

## Common Tasks

### Change Piwigo Version
Edit `Dockerfile` and update `PIWIGO_VERSION`, then redeploy.

### Change Port
Set `APP_PORT` in `.env` to the desired port.

### Add PHP Extensions
Edit the `Dockerfile` and add extensions to the `docker-php-ext-install` command.

### Backup
Backup the named volumes:
```bash
docker volume ls --filter name=piwigo
docker run --rm -v <volume_name>:/data -v $(pwd):/backup alpine tar czf /backup/<volume_name>.tar.gz -C /data .
```

## PHP Extensions Installed

- `pdo_mysql` - MySQL database driver
- `mysqli` - MySQL improved extension
- `gd` - Image manipulation (with freetype, jpeg, webp support)
- `exif` - EXIF data reading
- `zip` - ZIP archive support
- `opcache` - PHP opcode cache
