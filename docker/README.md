# Docker layout

## Arquitectura recomendada
La infraestructura persistente y el entorno de aplicacion se manejan ahora como dos proyectos Compose separados:

- `docker-compose.infra.yml`: servicios de datos compartidos y persistentes
- `docker-compose.yml`: servicios web y contenedores PHP usados por el workspace

Esto desacopla PostgreSQL, MySQL y Redis del ciclo de vida de VSCode Dev Containers. El Dev Container ya no arranca, recrea ni detiene la infraestructura.

## Servicios
### Infraestructura persistente
- `mysql`
- `postgresql`
- `redis`

### Aplicacion y workspace
- `php-nginx` + `nginx`
- `php-apache` + `apache`

Ambos proyectos se conectan a una red Docker compartida y estable:

- `php-projects-shared-services`

La red es externa a ambos proyectos Compose. Se crea una sola vez y luego ambos stacks la reutilizan.

## Volumenes de proyectos
Coloca tus proyectos PHP en el host:

- `./volumes-projects/nginx` para sitios servidos por Nginx
- `./volumes-projects/apache` para sitios servidos por Apache

Rutas dentro de contenedores:

- Nginx document root: `/var/www/nginx`
- Apache document root: `/var/www/apache`
- PHP Nginx (`php-nginx`) workspace: `/var/www/workspace` -> `./volumes-projects/nginx/${WEB_PROJECT_DIR_NGINX}`
- PHP Apache (`php-apache`) workspace: `/var/www/workspace` -> `./volumes-projects/apache/${WEB_PROJECT_DIR_APACHE}`

Ejemplo:

- `./volumes-projects/nginx/laravel-api`
- `./volumes-projects/apache/legacy-crm`

## Volumenes de datos
Persistencia en host:

- MySQL: `./volumes-data/mysql`
- PostgreSQL: `./volumes-data/postgresql`
- Redis: `./volumes-data/redis`

Nota: los datos de PostgreSQL quedan atados a la version mayor del motor. Si `./volumes-data/postgresql` fue inicializado con PostgreSQL 17, el contenedor tambien debe correr con 17, o debes migrar/resetear esos datos antes de bajar a 16.

## Arranque recomendado
### 1. Levantar infraestructura
Este paso deja los servicios de datos fuera del control de VSCode. El target `make infra-up` crea primero la red compartida si hace falta.

```bash
docker compose -f docker-compose.infra.yml up -d
```

Si usas el comando directo en un host limpio, crea la red una vez antes:

```bash
docker network inspect php-projects-shared-services >/dev/null 2>&1 || docker network create --driver bridge php-projects-shared-services
```

Atajo equivalente:

```bash
make infra-up
```

### 2. Levantar el stack de aplicacion que necesites
Stack Nginx:

```bash
docker compose up -d --build php-nginx nginx
```

Atajo equivalente:

```bash
make nginx-up
```

Stack Apache:

```bash
docker compose up -d --build php-apache apache
```

Atajo equivalente:

```bash
make apache-up
```

Ambos stacks a la vez:

```bash
docker compose up -d --build php-nginx nginx php-apache apache
```

Atajo equivalente:

```bash
make app-up
```

### 3. Abrir VSCode Dev Container
El Dev Container solo administra el contenedor PHP y su web server asociado. Antes de arrancar, asegura automaticamente que la red `php-projects-shared-services` exista y levanta `mysql` + `postgresql` desde `docker-compose.infra.yml`. `redis` sigue siendo manual para no cargar servicios no siempre necesarios.

## Acceso desde el host
Los servicios de datos se publican solo en loopback del host para evitar exposicion innecesaria:

- PostgreSQL: `127.0.0.1:${POSTGRES_PORT:-5432}`
- MySQL: `127.0.0.1:${MYSQL_PORT:-3306}`
- Redis: `127.0.0.1:${REDIS_PORT:-6379}`

Para DBeaver y herramientas del host usa:

- Host: `127.0.0.1`
- PostgreSQL port: `5432`

Evita `localhost` si tu cliente intenta primero IPv6.

URLs web por defecto:

- Nginx (PHP `${NGINX_PHP_VERSION}`): `http://localhost:80`
- Apache (PHP `${APACHE_PHP_VERSION}`): `http://localhost:8080`

## Dev Containers (VSCode)
Configuraciones disponibles:

- [`.devcontainer/devcontainer.json`](../.devcontainer/devcontainer.json) -> `php-nginx` + `nginx`
- [`.devcontainer/apache-php74/devcontainer.json`](../.devcontainer/apache-php74/devcontainer.json) -> `php-apache` + `apache`

Ambas configuraciones usan:

- `shutdownAction: "none"` para que cerrar VSCode no detenga el stack
- `runServices` limitado al servicio PHP y su web server

Para usar ambos en paralelo, abre dos ventanas de VSCode y selecciona una configuracion distinta en cada una.

El repositorio de infraestructura sigue disponible en `/workspaces/<nombre-del-repo>`.

### Hosts de servicios dentro del dev container
Cuando entras al workspace con Dev Containers, `localhost` y `127.0.0.1` apuntan al contenedor `php-nginx` o `php-apache`, no al host ni a otros servicios Docker.

Usa estos hosts desde la app que corre dentro del dev container:

- PostgreSQL: `postgresql:5432`
- MySQL: `mysql:3306`
- Redis: `redis:6379`

Si el servicio corre en tu maquina host y no dentro de Docker Compose, usa:

- Host machine desde el dev container: `host.docker.internal`

Si una aplicacion funciona fuera del dev container con `127.0.0.1` pero falla dentro, normalmente solo hay que cambiar `DB_HOST` o el host equivalente al nombre del servicio Docker.

## PHP por version
Cada version de PHP tiene su propia carpeta:

- `docker/php/8.4/`
- `docker/php/8.2/`
- `docker/php/7.4/`

Cada una incluye:

- `Dockerfile` (multi-stage)
- `php.ini`
- `xdebug.ini`

Configuracion compartida de shell:

- `docker/php/common/shell/.zshrc`
