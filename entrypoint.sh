#!/bin/sh
set -e

CONF_DIR="/var/www/html/local/config"
CONF_FILE="${CONF_DIR}/database.inc.php"
INSTALL_LOCK="${CONF_DIR}/piwigo_installed"

if [ ! -f "${INSTALL_LOCK}" ]; then
    mkdir -p "${CONF_DIR}"

    cat > "${CONF_FILE}" <<PHP
<?php
\$conf['dblayer'] = 'mysqli';
\$conf['db_base'] = '${PIWIGO_DB_NAME:-piwigo}';
\$conf['db_user'] = '${PIWIGO_DB_USER}';
\$conf['db_password'] = '${PIWIGO_DB_PASSWORD}';
\$conf['db_host'] = '${PIWIGO_DB_HOST:-piwigo-db}';
\$conf['db_prefix'] = '${PIWIGO_DB_PREFIX:-piwigo_}';
PHP
    chown www-data:www-data "${CONF_FILE}"
    echo "Generated ${CONF_FILE}"

    (while [ ! -f "${INSTALL_LOCK}" ]; do
        sleep 3
        if ! curl -sf http://localhost:80/ > /dev/null 2>&1; then
            continue
        fi

        echo "Running Piwigo installation..."
        BODY=$(curl -s -X POST "http://localhost:80/install.php?language=en_UK" \
            -d "install=true" \
            -d "dbhost=${PIWIGO_DB_HOST:-piwigo-db}" \
            -d "dbuser=${PIWIGO_DB_USER}" \
            -d "dbpasswd=${PIWIGO_DB_PASSWORD}" \
            -d "dbname=${PIWIGO_DB_NAME:-piwigo}" \
            -d "prefix=${PIWIGO_DB_PREFIX:-piwigo_}" \
            -d "admin_name=${PIWIGO_ADMIN_USER:-admin}" \
            -d "admin_pass1=${PIWIGO_ADMIN_PASSWORD}" \
            -d "admin_pass2=${PIWIGO_ADMIN_PASSWORD}" \
            -d "admin_mail=${PIWIGO_ADMIN_EMAIL:-admin@example.com}" 2>&1) || true

        if echo "${BODY}" | grep -qi "congratulations"; then
            touch "${INSTALL_LOCK}"
            chown www-data:www-data "${INSTALL_LOCK}"
            echo "Piwigo installation complete"
        else
            echo "Installation attempt did not succeed, retrying in 5s..."
            sleep 2
        fi
    done) &
fi

exec "$@"