#!/bin/sh
set -e

CONF_DIR="/var/www/html/local/config"
CONF_FILE="${CONF_DIR}/database.inc.php"
INSTALL_LOCK="/var/www/html/local/config/piwigo_installed"

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
fi

(while [ ! -f "${INSTALL_LOCK}" ]; do
    sleep 3
    if ! curl -sf http://localhost:80/ > /dev/null 2>&1; then
        continue
    fi

    echo "Running Piwigo installation..."
    BODY=$(curl -s -X POST "http://localhost:80/install.php" \
        -d "language=en_UK" \
        -d "dbhost=${PIWIGO_DB_HOST:-piwigo-db}" \
        -d "dbuser=${PIWIGO_DB_USER}" \
        -d "dbpasswd=${PIWIGO_DB_PASSWORD}" \
        -d "dbname=${PIWIGO_DB_NAME:-piwigo}" \
        -d "prefix=${PIWIGO_DB_PREFIX:-piwigo_}" \
        -d "admin_name=${PIWIGO_ADMIN_USER:-admin}" \
        -d "admin_pass1=${PIWIGO_ADMIN_PASSWORD}" \
        -d "admin_pass2=${PIWIGO_ADMIN_PASSWORD}" \
        -d "admin_mail=${PIWIGO_ADMIN_EMAIL:-admin@example.com}" \
        -d "install=Start+installation")

    if echo "${BODY}" | grep -q "Congratulations"; then
        touch "${INSTALL_LOCK}"
        chown www-data:www-data "${INSTALL_LOCK}"
        echo "Piwigo installation complete"
    else
        echo "Installation not yet complete, retrying..."
    fi
done) &

exec "$@"