# Docker layout

## Servicios compartidos
`docker-compose.yml` define los contenedores comunes:

- `php`
- `nginx`
- `apache`
- `mysql`
- `postgresql`
- `redis`

## Carpeta 1: volumenes de proyectos
Coloca tus proyectos PHP aqui (en el host):

- `./volumes-projects/nginx` para sitios servidos por Nginx
- `./volumes-projects/apache` para sitios servidos por Apache

Rutas dentro de contenedores:

- Nginx document root: `/var/www/nginx`
- Apache document root: `/var/www/apache`
- PHP monta ambos paths para ejecutar codigo de los dos stacks
- PHP monta ademas `/var/www/workspace` segun `WEB_SERVER` (`nginx` o `apache`) y `WEB_PROJECT_DIR`

Ejemplo:

- `./volumes-projects/nginx/laravel-api`
- `./volumes-projects/apache/legacy-crm`

## Carpeta 2: volumenes de datos (persistencia)
Datos persistentes en el host:

- MySQL: `./volumes-data/mysql`
- PostgreSQL: `./volumes-data/postgresql`
- Redis: `./volumes-data/redis`

## Seleccionar stack web activo
En `.env` configura:

- `WEB_SERVER=nginx` o `WEB_SERVER=apache`
- `WEB_PROJECT_DIR=.` para abrir la raiz del stack elegido:
  - `./volumes-projects/nginx` si `WEB_SERVER=nginx`
  - `./volumes-projects/apache` si `WEB_SERVER=apache`
- `WEB_PROJECT_DIR=inventario-polar` para abrir una subcarpeta del stack elegido:
  - `./volumes-projects/nginx/inventario-polar` si `WEB_SERVER=nginx`
  - `./volumes-projects/apache/inventario-polar` si `WEB_SERVER=apache`

Si cambias `WEB_SERVER` o `WEB_PROJECT_DIR`, reconstruye los contenedores para refrescar el bind mount.

## Dev Containers (VSCode)
El Dev Container abre `/var/www/workspace`, que apunta al volumen elegido por `WEB_SERVER` + `WEB_PROJECT_DIR`.

El repositorio de infraestructura sigue disponible en `/workspaces/<nombre-del-repo>`.

Xdebug ya incluye mapeos para ambos roots remotos:

- `/var/www/workspace` -> `/var/www/workspace`
- `/var/www/nginx` -> `/var/www/nginx`
- `/var/www/apache` -> `/var/www/apache`

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

## Cambiar version de PHP
1. Copia `.env.example` a `.env`.
2. Cambia `PHP_VERSION` (`8.4`, `8.2`, `7.4` o la que crees).
3. Reconstruye:

```bash
docker compose down
docker compose up -d --build
```

## Agregar otra version de PHP
1. Duplica `docker/php/8.4` a `docker/php/<nueva-version>`.
2. Ajusta imagen base y configuraciones.
3. Define `PHP_VERSION=<nueva-version>` en `.env` y reconstruye.
