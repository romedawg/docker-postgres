#Download base image ubuntu 20.04
FROM ubuntu:20.04

LABEL maintaier="admin@romedawg.com"
LABEL version="0.1"
LABEL description="This is custom Docker Image for the PostgresSQL."

ARG POSTGRES_VERSION=14
ARG POSTGRES_CONTRIB_VERSION=9.6

# Postgres Settings
ARG POSTGRES_DATA_DIR=/var/lib/postgresql
ARG POSTGRES_CONFIG_DIR=/etc/postgresql
ARG POSTGRES_CONFIG=${POSTGRES_CONFIG_DIR}/postgresql.conf
ARG POSTGRES_HBA_CONFIG=${POSTGRES_CONFIG_DIR}/pg_hba.conf
ARG POSTGRES_PG_INDENT_CONFIG=${POSTGRES_CONFIG_DIR}/pg_ident.conf
ARG POSTGRES_LOG_DIR=/var/log/postgresql

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

# Update Ubuntu Software repository & install postgres
RUN set -x \
    && apt-get update \
    && apt-get -y install vim bash-completion wget gnupg2 lsb-release \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get -y install postgresql-${POSTGRES_VERSION} postgresql-client-${POSTGRES_VERSION}

RUN set -x \
    && rm -rf /var/lib/apt/lists/* /var/cache/* /tmp/* /var/tmp/* /var/log/* ${POSTGRES_DATA_DIR}/* ${POSTGRES_CONFIG_DIR}/*

COPY docker-entrypoint.sh docker-healthcheck.sh /usr/local/bin/
COPY postgresql.conf /tmp/postgresql.conf
COPY pg_hba.conf /tmp/pg_hba.conf
COPY pg_ident.conf /tmp/pg_ident.conf

# Postgres config files/directories
RUN set -x \
    && chmod a+x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/docker-healthcheck.sh \
    && mv /tmp/postgresql.conf ${POSTGRES_CONFIG} \
    && mv /tmp/pg_hba.conf ${POSTGRES_HBA_CONFIG} \
    && mv /tmp/pg_ident.conf ${POSTGRES_PG_INDENT_CONFIG} \
    && chown -R postgres:postgres ${POSTGRES_CONFIG_DIR} \
    && mkdir -p ${POSTGRES_DATA_DIR} \
    && chown -R postgres:postgres ${POSTGRES_DATA_DIR} \
    && chmod -R 0700 ${POSTGRES_DATA_DIR}

RUN set -x \
    && mkdir -p ${POSTGRES_LOG_DIR} \
    && chown -R postgres:postgres ${POSTGRES_LOG_DIR}

EXPOSE 5432

USER postgres

HEALTHCHECK CMD ["/usr/local/bin/docker-healthcheck.sh"]

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
