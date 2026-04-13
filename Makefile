.PHONY: test up down clean reset

test: reset
	@echo "Running Fibonacci test..."
	@PGPASSWORD=npg_Ljo6FzUiyfh9 psql "$(DATABASE_URL)" -f tests/fibonacci.sql
	@echo "Test complete"

reset:
	@echo "Loading schema..."
	@for f in init/*.sql; do \
		PGPASSWORD=npg_Ljo6FzUiyfh9 psql "$(DATABASE_URL)" -f "$$f" || exit 1; \
	done

up:
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v
