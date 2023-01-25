DOCKER_COMPOSE := docker-compose
DOCKER_COMPOSE_RUN := docker-compose run --rm

.PHONY: rspec
rspec:
	${DOCKER_COMPOSE_RUN} web bundle exec rspec

.PHONY: lint
lint:
	${DOCKER_COMPOSE_RUN} web bundle exec rubocop -A

.PHONY: migrate
migrate:
	${DOCKER_COMPOSE_RUN} web rails db:migrate

.PHONY: bundle_install
bundle_install:
	${DOCKER_COMPOSE_RUN} web bundle install
