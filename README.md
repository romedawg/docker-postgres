# docker-postgres

Introduction

This repository contains the Dockerfiles used to build a PostgresSQL server, currently built and maintained  for:
PostgresSQL 14.0

# building
```
docker build -t postgres .
```

# running
Set these variables
```
POSTGRES_DATABASE=romedawg 
ADMIN_USER=roman
ADMIN_PASSWORD=password
```

Run the container
```
docker run -d --env-file /tmp/postgres_creds.txt -p 5432:5432 --name postgres postgres
```

# tests

# TODO 
 - Healthchecks
 - Tests - create them
   - Standalone
   - Replica
   - Backup and Restore
   - Create Test application to read/write  
 - Generate certificates to use(or default ones may be ok)
 - Deploy to ECS
 - fix logging
    - try logging in with a non existing user, docker will show error. postgres no.. actually no logs

# ansible Playbook

