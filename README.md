# Infra

Shared Postgres + Redis for all projects on the server.

## Setup

```bash
cp .env.example .env
# Fill in passwords in .env
docker compose up -d
```

## Add a new project

```bash
docker exec -it infra-postgres-1 psql -U postgres
```

```sql
CREATE USER mybot WITH PASSWORD 'strong-password';
CREATE DATABASE mybot_db OWNER mybot;
```

## Connect from a bot's docker-compose.yml

```yaml
services:
  bot:
    # ...
    environment:
      DATABASE_URL: postgresql://mybot:password@postgres:5432/mybot_db
      REDIS_URL: redis://:redis-password@redis:6379/0
    networks:
      - infra

networks:
  infra:
    external: true
```

Use different Redis DB numbers (`/0`, `/1`, `/2`...) per project.

## Connect from TablePlus / DBeaver

Use SSH tunnel to the server, then connect to `127.0.0.1:5432`.

## Backup

```bash
docker exec infra-postgres-1 pg_dumpall -U postgres | gzip > ~/backups/pg_$(date +%F).sql.gz
```

## Migrate existing bot database

```bash
# Dump from old container
docker exec old-postgres-container pg_dump -U postgres -d old_db > ~/backup.sql

# Create user and database
docker exec -it infra-postgres-1 psql -U postgres
# CREATE USER ... ; CREATE DATABASE ... ;

# Restore
cat ~/backup.sql | docker exec -i infra-postgres-1 psql -U postgres -d new_db
```
