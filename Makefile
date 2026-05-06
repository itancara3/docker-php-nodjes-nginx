.PHONY: network-up devcontainer-init infra-up infra-down infra-ps infra-logs nginx-up apache-up app-up app-down down ps config

NETWORK_NAME ?= php-projects-shared-services

network-up:
	docker network inspect $(NETWORK_NAME) >/dev/null 2>&1 || docker network create --driver bridge $(NETWORK_NAME)

devcontainer-init: network-up
	docker compose -f docker-compose.infra.yml up -d mysql postgresql redis

infra-up: network-up
	docker compose -f docker-compose.infra.yml up -d

infra-down:
	docker compose -f docker-compose.infra.yml down

infra-ps:
	docker compose -f docker-compose.infra.yml ps

infra-logs:
	docker compose -f docker-compose.infra.yml logs -f

nginx-up: infra-up
	docker compose up -d --build php-nginx nginx

apache-up: infra-up
	docker compose up -d --build php-apache apache

app-up: infra-up
	docker compose up -d --build php-nginx nginx php-apache apache

app-down:
	docker compose down

down: app-down infra-down

ps:
	docker compose -f docker-compose.infra.yml ps
	docker compose ps

config:
	docker compose -f docker-compose.infra.yml config
	docker compose config
