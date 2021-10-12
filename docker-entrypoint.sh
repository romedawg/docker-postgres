#!/usr/bin/env bash

set -o pipefail
set -eux
#
POSTGRES_USER=${POSTGRES_USER:-postgres}
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-password}
PWFILE=/tmp/postgres_password
PG_DATA=${PG_DATA:-/var/lib/postgresql/main}
POSTGRES_LOGS_DIR=/var/log/postgresql
POSTGRES_LOGS_FILE=/var/log/postgresql/postgresql.log
POSTGRES_CLUSTER=${POSTGRES_CLUSTER:-genera}
POSTGRES_CONFIG=${POSTGRES_CONFIG:-/etc/postgresql/postgresql.conf}

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

  cat <<< "${POSTGRES_PASSWORD}" > "${PWFILE}"

  return 0

}

function initialize_database() {

  /usr/lib/postgresql/14/bin/initdb --pgdata="${PG_DATA}" --username="${POSTGRES_USER}" --pwfile="${PWFILE}" --data-checksums

  rm "${PWFILE}"

  return 0

}

setup_environment || exit 1
initialize_database || exit 1

# Working
eval "exec /usr/lib/postgresql/14/bin/postgres -D ${PG_DATA} -c config_file=/etc/postgresql/postgresql.conf"

# What i should get working...maybe?
#eval "exec /usr/lib/postgresql/14/bin/pg_ctl -D ${PG_DATA} -l ${POSTGRES_LOGS_FILE} start"
