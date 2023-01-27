DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_RUN := docker-compose run --rm

.PHONY: setup
setup:
	@${DOCKER_COMPOSE} build
	@make bundle_install
	@make db_create
	@make db_migrate
	@make es_index_create

.PHONY: rspec
rspec:
	${DOCKER_COMPOSE_RUN} web bundle exec rspec

.PHONY: lint
lint:
	${DOCKER_COMPOSE_RUN} web bundle exec rubocop -A

.PHONY: db_create
create:
	${DOCKER_COMPOSE_RUN} web rails db:create

.PHONY: db_migrate
migrate:
	${DOCKER_COMPOSE_RUN} web rails db:migrate

.PHONY: bundle_install
bundle_install:
	${DOCKER_COMPOSE_RUN} web bundle install

.PHONY: up
up:
	${DOCKER_COMPOSE} up -d

.PHONY: down
down:
	${DOCKER_COMPOSE} down

.PHONY: es_index_create
es_index_create:
	${DOCKER_COMPOSE_RUN} web rails es_index:create
