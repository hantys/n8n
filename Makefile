ARG=

DOCKER_COMPOSE ?= $(shell \
		docker compose version >/dev/null 2>/dev/null \
	&& echo docker compose \
	|| echo docker-compose \
	)

start-build:
	$(DOCKER_COMPOSE) up -d --build --remove-orphans

start:
	$(DOCKER_COMPOSE) up -d

stop:
	$(DOCKER_COMPOSE) down; docker system prune -f

restart:
	make stop ; make start-build  