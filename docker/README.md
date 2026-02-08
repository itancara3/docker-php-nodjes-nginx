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

Ejemplo:

- `./volumes-projects/nginx/laravel-api`
- `./volumes-projects/apache/legacy-crm`

## Carpeta 2: volumenes de datos (persistencia)
Datos persistentes en el host:

- MySQL: `./volumes-data/mysql`
- PostgreSQL: `./volumes-data/postgresql`
- Redis: `./volumes-data/redis`

## Dev Containers (VSCode)
El workspace del contenedor abre este repositorio (`/workspaces/...`), por lo que puedes editar infraestructura y proyectos en:

- `volumes-projects/nginx`
- `volumes-projects/apache`

Xdebug ya incluye mapeos para ambos roots remotos:

- `/var/www/nginx` -> `${workspaceFolder}/volumes-projects/nginx`
- `/var/www/apache` -> `${workspaceFolder}/volumes-projects/apache`

## PHP por version
Cada version de PHP tiene su propia carpeta:

- `docker/php/8.4/`
- `docker/php/8.2/`

Cada una incluye:

- `Dockerfile` (multi-stage)
- `php.ini`
- `xdebug.ini`

Configuracion compartida de shell:

- `docker/php/common/shell/.zshrc`

## Cambiar version de PHP
1. Copia `.env.example` a `.env`.
2. Cambia `PHP_VERSION` (`8.4`, `8.2` o la que crees).
3. Reconstruye:

```bash
docker compose down
docker compose up -d --build
```

## Agregar otra version de PHP
1. Duplica `docker/php/8.4` a `docker/php/<nueva-version>`.
2. Ajusta imagen base y configuraciones.
3. Define `PHP_VERSION=<nueva-version>` en `.env` y reconstruye.
