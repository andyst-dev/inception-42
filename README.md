# inception

A small containerized web infrastructure developed as part of the 42 curriculum.
`inception` is a Docker-based infrastructure project that brings together NGINX, WordPress and MariaDB in a multi-service setup.

It was a good way to build solid foundations in container orchestration, service isolation, networking, persistent storage, TLS setup and automated service provisioning.

## Features
- Multi-container infrastructure managed with Docker Compose
- NGINX configured as the single HTTPS entry point
- TLS enabled with TLSv1.2 and TLSv1.3
- WordPress running with php-fpm in its own container
- MariaDB running in a dedicated container
- Persistent volumes for database data and website files
- Environment-based configuration and Docker secrets support
- Automatic service restart policy

## Project structure
- `Makefile` — sets up host data directories and manages build / startup commands
- `srcs/docker-compose.yml` — defines services, volumes, secrets and network
- `srcs/.env` — environment variables used by the stack configuration
- `srcs/requirements/nginx/` — NGINX Dockerfile, TLS setup script and server configuration
- `srcs/requirements/wordpress/` — WordPress / php-fpm Dockerfile and setup script
- `srcs/requirements/mariadb/` — MariaDB Dockerfile, server config and initialization script
- `secrets/` — local secret files used by the containers at runtime

## Mandatory part
The mandatory part focuses on the Docker-based infrastructure required to run the different services in separate containers.

### Services
- `nginx` — HTTPS entry point serving the WordPress site and forwarding PHP requests to php-fpm
- `wordpress` — installs and runs WordPress with php-fpm
- `mariadb` — initializes and runs the WordPress database

### Core behavior
- builds each service from its own Dockerfile
- runs one dedicated container per service
- connects the containers through a custom bridge network
- stores database and website data in persistent host-mounted volumes
- exposes only port `443` through NGINX
- generates and uses an SSL certificate for HTTPS access
- initializes MariaDB and WordPress automatically on first launch
- injects configuration through environment variables and Docker secrets

### What happens at runtime
- the Makefile creates the local data directories and prepares host mapping for the domain
- Docker Compose builds the three service images from the local Dockerfiles
- MariaDB starts first and initializes the database and SQL user
- WordPress waits for MariaDB, downloads the core files, creates `wp-config.php`, installs the site and creates a second user
- NGINX generates the certificate if needed, serves the WordPress files and forwards PHP requests to the WordPress container
- persistent volumes keep database content and website files across container restarts

### Subject requirements to respect
- the whole project must run through Docker Compose
- each service must run in its own dedicated container
- images must be built from custom Dockerfiles
- NGINX must be the only public entry point
- access must happen only through port `443` with TLS
- WordPress must run with php-fpm, without nginx inside the container
- MariaDB must run in its own container
- the setup must use environment variables
- passwords must not be hardcoded in Dockerfiles
- persistent storage must be handled through volumes

## Notes
This repository focuses on the mandatory infrastructure setup with Docker Compose.
The project is built around service separation: the database, PHP application layer and web server each run independently and communicate through the Docker network.

It also relies on first-run automation.
The MariaDB container initializes the database and SQL user, the WordPress container installs the site and creates both the admin and a second user and the NGINX container handles HTTPS termination for the whole stack.

```text
                +-----------+          Host client
                |  Browser  |          HTTPS access
                +-----------+
                      |
                    HTTPS
                      |
                +-----------+          Public entry point
                |   NGINX   |          Reverse proxy + TLS
                +-----------+
                      |
                +-----------+          App layer
                | WordPress |          php-fpm container
                +-----------+
                      |
                +-----------+          Data layer
                |  MariaDB  |          Persistent storage
                +-----------+

Network:
- Docker network

Volumes:
- website files
- database data
```

## Usage
Create your local configuration files first:

```bash
cp srcs/.env.example srcs/.env
cp secrets/*.example secrets/
# then rename the copied secret files and replace their placeholder values
```

These files are used to provide runtime secrets to the containers and should be filled with real local values before starting the stack.

Build and start the infrastructure:

```bash
make
```

Stop the containers:

```bash
make down
```

Quick checks:

```bash
docker ps
docker compose -f srcs/docker-compose.yml ps
docker compose -f srcs/docker-compose.yml logs nginx
```

Clean Docker resources:

```bash
make clean
```

Remove containers, volumes and local data:

```bash
make fclean
```

Rebuild everything from scratch:

```bash
make re
```

## Learning outcomes
This project was my first real introduction to building a small service-oriented infrastructure with Docker.
It helped build solid foundations in:
- Dockerfiles and Docker Compose
- container networking
- persistent volumes
- environment-based configuration
- secret handling
- TLS setup with NGINX
- WordPress and MariaDB service orchestration
- automated first-run provisioning
