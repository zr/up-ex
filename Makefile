.PHONY: rspec
rspec:
	docker-compose run --rm web bundle exec rspec

.PHONY: lint
lint:
	docker-compose run --rm web bundle exec rubocop -A

.PHONY: migrate
migrate:
	docker-compose run --rm web rails db:migrate