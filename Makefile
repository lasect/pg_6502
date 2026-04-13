.PHONY: test up down clean reset

DATABASE_URL = postgresql://neondb_owner:npg_Ljo6FzUiyfh9@ep-fragrant-frog-amtonlwn-pooler.c-5.us-east-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require

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