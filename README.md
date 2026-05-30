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

### Deploy on Coolify (from public GitHub repo)

1. **Create a new resource**
   - From your Coolify dashboard, select your project
   - Click **+ New** to create a new resource

2. **Select Public Repository**
   - Choose **Public Repository** from the available resource types

3. **Choose your server**
   - Select the server where you want to deploy Piwigo

4. **Enter the repository URL**
   - Paste: `https://github.com/bigcalm/piwigo-on-coolify`
   - The `main` branch will be automatically selected
   - Click **Check Repository**

5. **Configure and deploy**
   - Coolify will detect the `docker-compose.yml` file
   - Set the required environment variables in Coolify's UI:
     - `MYSQL_ROOT_PASSWORD` — set a strong password
     - `MYSQL_PASSWORD` — set a strong password for the Piwigo database user
   - (Optional) Assign a domain to the `piwigo-nginx` service for SSL
   - Click **Deploy**

### Local Development

1. Clone the repository:

   ```bash
   git clone https://github.com/bigcalm/piwigo-on-coolify.git
   cd piwigo-on-coolify
   ```

2. Copy and configure the environment file:

   ```bash
   cp .env.example .env
   ```

3. Edit `.env` and set secure passwords:

   ```env
   MYSQL_ROOT_PASSWORD=your_secure_root_password
   MYSQL_PASSWORD=your_secure_piwigo_password
   ```

4. Start the services:

   ```bash
   docker compose up -d --build
   ```

## Configuration

### Environment Variables

Coolify automatically detects variables from `docker-compose.yml` and displays them in the UI.

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

After deployment, navigate to your Piwigo instance URL. If you assigned a domain in Coolify, use that URL. Otherwise, use your server IP with the configured port.

Complete the Piwigo installation wizard using these database credentials:

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
