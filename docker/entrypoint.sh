#!/usr/bin/env bash
set -euo pipefail

GF_HOME=/opt/glassfish7
ASADMIN="${GF_HOME}/bin/asadmin"
DOMAIN="domain1"

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"
DB_NAME="${DB_NAME:-lab_db}"
DB_USER="${DB_USER:-lab_user}"
DB_PASSWORD="${DB_PASSWORD:-lab_pass}"
APP_CONTEXT="${APP_CONTEXT:-lab}"

ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_PASS="${ADMIN_PASS:-admin123}"

echo "Waiting for Postgres at ${DB_HOST}:${DB_PORT}..."
until nc -z "${DB_HOST}" "${DB_PORT}"; do sleep 1; done
echo "Postgres is up."

# старт домена (в фоне), чтобы выполнить настройки
"${ASADMIN}" start-domain "${DOMAIN}"

# файлы пароля
PWCHANGE=/tmp/pwchange
cat > "${PWCHANGE}" <<EOF
AS_ADMIN_PASSWORD=
AS_ADMIN_NEWPASSWORD=${ADMIN_PASS}
EOF

PW=/tmp/pw
cat > "${PW}" <<EOF
AS_ADMIN_PASSWORD=${ADMIN_PASS}
EOF
chmod 600 "${PWCHANGE}" "${PW}"

# хелперы (plain/secure)
A_PLAIN=( "${ASADMIN}" --host localhost --port 4848 )
A_AUTH_PLAIN=( "${ASADMIN}" --host localhost --port 4848 --user "${ADMIN_USER}" --passwordfile "${PW}" )
A_AUTH_SECURE=( "${ASADMIN}" --host localhost --port 4848 --secure=true --user "${ADMIN_USER}" --passwordfile "${PW}" )

# инициализация один раз на контейнер (для обхода повотрной смены пароля)
INIT_MARK="${GF_HOME}/.initdone"
if [[ ! -f "${INIT_MARK}" ]]; then
  # 1) сменить пароль (первый раз - старый пустой)
  "${A_PLAIN[@]}" --user "${ADMIN_USER}" --passwordfile "${PWCHANGE}" change-admin-password || true

  # 2) чтобы админка слушала наружу из контейнера
  "${A_AUTH_PLAIN[@]}" set configs.config.server-config.network-config.network-listeners.network-listener.admin-listener.address=0.0.0.0 || true

  # 3) включить secure-admin (для входа в админку с хоста)
  "${A_AUTH_PLAIN[@]}" enable-secure-admin || true

  # 4) рестарт домена
  "${A_PLAIN[@]}" restart-domain "${DOMAIN}"

  touch "${INIT_MARK}"
else
  echo "GlassFish already initialized; skipping password/secure-admin."
fi

# secure-admin - делаем через --secure=true + авторизация

# JDBC pool
if ! "${A_AUTH_SECURE[@]}" list-jdbc-connection-pools | grep -qx "LabPool"; then
  "${A_AUTH_SECURE[@]}" create-jdbc-connection-pool \
    --restype=javax.sql.DataSource \
    --datasourceclassname=org.postgresql.ds.PGSimpleDataSource \
    --property "user=${DB_USER}:password=${DB_PASSWORD}:databaseName=${DB_NAME}:serverName=${DB_HOST}:portNumber=${DB_PORT}" \
    LabPool
fi

# JDBC resource
if ! "${A_AUTH_SECURE[@]}" list-jdbc-resources | grep -qx "jdbc/labDS"; then
  "${A_AUTH_SECURE[@]}" create-jdbc-resource --connectionpoolid LabPool jdbc/labDS
fi

# Deploy
"${A_AUTH_SECURE[@]}" deploy --force=true --contextroot "${APP_CONTEXT}" --name app /opt/app.war

# переводим домен в foreground (чтобы контейнер работал с одним процессом)
"${A_PLAIN[@]}" stop-domain "${DOMAIN}"
exec "${ASADMIN}" start-domain --verbose "${DOMAIN}"
