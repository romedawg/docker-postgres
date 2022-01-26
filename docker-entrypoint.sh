#!/usr/bin/env bash

set -o pipefail
set -eu

function setup_environment() {

  if [ ! -d "${PG_DATA}" ];then
    mkdir -p "${PG_DATA}"
    chown -R postgres:postgres "${PG_DATA}"
  fi

  if [ ! -d "${POSTGRES_LOGS_DIR}" ];then
    mkdir "${POSTGRES_LOGS_DIR}"
    chown -R postgres:postgres "${POSTGRES_LOGS_DIR}"
  fi

  if [ ! -f "${POSTGRES_LOGS_FILE}" ];then
    touch "${POSTGRES_LOGS_FILE}"
    chown -R postgres:postgres "${POSTGRES_LOGS_FILE}"
  fi

  cat <<< "${POSTGRES_DEFAULT_PASSWORD}" > "${PW_FILE}"

  return 0

}

function initialize_database() {

  /usr/lib/postgresql/14/bin/initdb --pgdata="${PG_DATA}" --username="${POSTGRES_DEFAULT_USER}" --pwfile="${PW_FILE}" --data-checksums

  rm "${PW_FILE}"

  return 0

}

# Used mainly for docker tests/healthcheck user but also to setup initial users
function setupUsers() {

  temp_sql=$(mktemp /tmp/user_update.XXXXXX)

  if [[ "${ADMIN_USER}" != nil && "${ADMIN_PASSWORD}" != nil && "${POSTGRES_DATABASE}" != nil ]];then
    /usr/lib/postgresql/14/bin/pg_ctl -D "${PG_DATA}" -l ${POSTGRES_LOGS_FILE} start
    # create grants for these users for database x
    /usr/lib/postgresql/14/bin/createuser --superuser "${ADMIN_USER}"
    /usr/lib/postgresql/14/bin/createdb "${POSTGRES_DATABASE}"

    cat <<< "ALTER USER ${ADMIN_USER} PASSWORD '${ADMIN_PASSWORD}'" > "${temp_sql}"
    psql -a -q -f "${temp_sql}"
    /usr/lib/postgresql/14/bin/pg_ctl -D "${PG_DATA}" stop
    rm "${temp_sql}"
  fi

  return 0
}

# postgres settings/configs/directories
POSTGRES_DEFAULT_USER=${POSTGRES_DEFAULT_USER:-postgres}
POSTGRES_DEFAULT_PASSWORD=${POSTGRES_DEFAULT_PASSWORD:-password}
PW_FILE=/tmp/postgres_password
PG_DATA=${PG_DATA:-/var/lib/postgresql/main}
POSTGRES_LOGS_DIR=/var/log/postgresql
POSTGRES_LOGS_FILE=/var/log/postgresql/postgresql.log
POSTGRES_CLUSTER=${POSTGRES_CLUSTER:-genera}
POSTGRES_CONFIG=${POSTGRES_CONFIG:-/etc/postgresql/postgresql.conf}

# additional users/databases
POSTGRES_DATABASE=${POSTGRES_DATABASE:-nil}
ADMIN_USER=${ADMIN_USER:-nil}
ADMIN_PASSWORD=${ADMIN_PASSWORD:-nil}
POSTGRES_HEALTHCHECK_USER=${POSTGRES_HEALTHCHECK_USER:-healthcheck}
POSTGRES_HEALTHCHECK_PASSWD=${MYSQL_HEALTHCHECK_PASSWD:-nil}

setup_environment || exit 1
initialize_database || exit 1
setupUsers || exit 1

eval "exec /usr/lib/postgresql/14/bin/postgres -D ${PG_DATA} -c config_file=/etc/postgresql/postgresql.conf"

# What i should get working...maybe?
#eval "exec /usr/lib/postgresql/14/bin/pg_ctl -D ${PG_DATA} -l ${POSTGRES_LOGS_FILE} start"
