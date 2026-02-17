up:
	docker compose up -d

down:
	docker compose down

build:
	docker compose build

prune:
	docker system prune -a --volumes

logs:
	docker compose logs -f