#!/usr/bin/env bash

set -o pipefail
set -eux
#
#POSTGRES_USER=${POSTGRES_USER:-postgres}
#POSTGRES_PASSWORD=${POSTGRES_USER:-password}

#func initialize_postgres(){
#  psql -c "alter user ${POSTGRES_USER} with password '${POSTGRES_PASSWORD}'"
#}

eval "exec /usr/lib/postgresql/14/bin/postgres -D /var/lib/postgresql/14/main -c config_file=/etc/postgresql/postgresql.conf"


