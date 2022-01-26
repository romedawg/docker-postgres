#!/usr/bin/env bash

set -o pipefail
set -eu

POSTGRES_STATUS_CODE=""

if /usr/lib/postgresql/14/bin/pg_isready -d postgres://localhost:5432/template; then
  POSTGRES_STATUS_CODE="200";
else
  POSTGRES_STATUS_CODE="500";
  exit 1
fi

exit 0


