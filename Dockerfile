#Download base image ubuntu 20.04
FROM ubuntu:20.04

LABEL maintaier="admin@romedawg.com"
LABEL version="0.1"
LABEL description="This is custom Docker Image for the PostgresSQL."

# Disable Prompt During Packages Installation
ARG DEBIAN_FRONTEND=noninteractive

COPY docker-entrypoint.sh docker-healthcheck.sh /usr/local/bin/

# Update Ubuntu Software repository
RUN set -x \
    && apt-get update \
    && apt-get -y install vim bash-completion wget gnupg2 lsb-release \
    && wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ `lsb_release -cs`-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && apt-get install postgresql-13 postgresql-client-13

EXPOSE 5432

VOLUME ["/var/log/postgresql", "/var/lib/postgresql/"]

HEALTHCHECK CMD ["/usr/local/bin/docker-healthcheck.sh"]

# Need installation, healthcheck, terypoint.

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

