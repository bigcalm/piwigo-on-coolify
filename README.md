# Piwigo on Coolify

A self-contained project to deploy [Piwigo](https://piwigo.org/) photo gallery on [Coolify](https://coolify.io/).

> This project was created using [opencode](https://opencode.ai).

## Overview

This deployment includes:

- **Piwigo** - Open-source photo gallery software (PHP 8.3)
- **MariaDB 11** - Database server
- **Nginx** - Reverse proxy and static file serving
- **Supervisor** - Process management for PHP-FPM and Nginx

## Prerequisites

- A Coolify instance (v4.x)
- Docker and Docker Compose support
- A domain name (optional, for SSL)

## Quick Start

1. Clone or fork this repository
2. Copy the environment file and configure it:

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and set secure passwords:

   ```env
   MYSQL_ROOT_PASSWORD=your_secure_root_password
   MYSQL_PASSWORD=your_secure_piwigo_password
   ```

4. Deploy on Coolify:
   - Add a new resource in Coolify
   - Select "Docker Compose" as the deployment type
   - Point to this repository
   - Configure the environment variables
   - Deploy

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TZ` | Timezone | `UTC` |
| `APP_PORT` | Port exposed by Nginx | `8080` |
| `MYSQL_ROOT_PASSWORD` | MariaDB root password | _(required)_ |
| `MYSQL_DATABASE` | Database name for Piwigo | `piwigo` |
| `MYSQL_USER` | Database user for Piwigo | `piwigo` |
| `MYSQL_PASSWORD` | Database password for Piwigo user | _(required)_ |

### Volumes

The following persistent volumes are created:

- `piwigo-db-data` - MariaDB database files
- `piwigo-gallery-data` - Uploaded photos and thumbnails
- `piwigo-local-data` - Local configuration and plugins
- `piwigo-upload-data` - Upload directory

## First Setup

After deployment, navigate to your Piwigo instance URL to complete the installation wizard. Use the database credentials from your `.env` file:

- **Database host**: `piwigo-db`
- **Database port**: `3306`
- **Database name**: Value of `MYSQL_DATABASE`
- **Database user**: Value of `MYSQL_USER`
- **Database password**: Value of `MYSQL_PASSWORD`
- **Table prefix**: `piwigo_`

## Updating Piwigo

To update Piwigo to a newer version, modify the `PIWIGO_VERSION` build argument in the `Dockerfile` and redeploy.

## Project Structure

```
piwigo-on-coolify/
├── docker-compose.yml    # Service definitions
├── Dockerfile            # Piwigo application image
├── supervisord.conf      # Process manager configuration
├── nginx/
│   ├── default.conf      # Nginx site configuration
│   ├── nginx.conf        # Nginx main configuration
│   └── php-fpm.conf      # PHP-FPM pool configuration
├── .env.example          # Environment template
├── README.md
├── LICENSE
└── AGENTS.md
```

## License

MIT - See [LICENSE](LICENSE) for details.
