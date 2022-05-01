.PHONY: all up down help

all: up

up: ## Docker compose run
	docker-compose up --build -d

down: ## Docker compose run
	docker-compose down

help: ## Display available commands
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
