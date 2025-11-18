COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = $(HOME)/data

all: setup build up

setup:
	@mkdir -p $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	@grep -q "astoll.42.fr" /etc/hosts || echo "127.0.0.1 astoll.42.fr" | sudo tee -a /etc/hosts

build:
	@docker-compose -f $(COMPOSE_FILE) build

up:
	@docker-compose -f $(COMPOSE_FILE) up -d

down:
	@docker-compose -f $(COMPOSE_FILE) down

clean: down
	@docker system prune -af

fclean: down
	@docker system prune -af --volumes
	@sudo rm -rf $(DATA_DIR)/mariadb/* $(DATA_DIR)/wordpress/*

re: fclean all

.PHONY: all build up down clean fclean re