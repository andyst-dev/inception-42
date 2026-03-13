# inception

A small containerized web infrastructure developed as part of the 42 curriculum.
This project consists of building a multi-service setup with Docker Compose, including NGINX with TLS, WordPress with php-fpm, and MariaDB, along with persistent volumes, a dedicated network, and environment-based configuration.

`inception` was a good way to go deeper into system administration through container orchestration, service isolation, networking, persistent storage, TLS setup, and automated service provisioning.

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
- `srcs/docker-compose.yml` — defines services, volumes, secrets, and network
- `srcs/.env` — environment variables used by the stack configuration
- `srcs/requirements/nginx/` — NGINX Dockerfile, TLS setup script, and server configuration
- `srcs/requirements/wordpress/` — WordPress / php-fpm Dockerfile and setup script
- `srcs/requirements/mariadb/` — MariaDB Dockerfile, server config, and initialization script
- `secrets/` — local secret files used by the containers at runtime

## Mandatory part
The mandatory part implements a small Docker-based infrastructure running the required 42 services in separate containers.

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
- WordPress waits for MariaDB, downloads the core files, creates `wp-config.php`, installs the site, and creates a second user
- NGINX generates the certificate if needed, serves the WordPress files, and forwards PHP requests to the WordPress container
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
The project is centered on service separation: the database, PHP application layer, and web server each run independently and communicate through the Docker network.

It is also built around first-run automation.
The MariaDB container initializes the database and SQL user, the WordPress container installs the site and creates both the admin and a second user, and the NGINX container handles HTTPS termination for the whole stack.

## Usage
Create your local configuration files first:

```bash
cp srcs/.env.example srcs/.env
cp secrets/*.example secrets/
# then rename the copied secret files and replace their placeholder values
```

Build and start the infrastructure:

```bash
make
```

Stop the containers:

```bash
make down
```

Clean Docker resources:

```bash
make clean
```

Remove containers, volumes, and local data:

```bash
make fclean
```

Rebuild everything from scratch:

```bash
make re
```

## Learning outcomes
This project was my introduction to building a small service-oriented infrastructure with Docker.
It helped me get more comfortable with:
- Dockerfiles and Docker Compose
- container networking
- persistent volumes
- environment-based configuration
- secret handling
- TLS setup with NGINX
- WordPress and MariaDB service orchestration
- automated first-run provisioning
