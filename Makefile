.PHONY: test up down clean reset

test: reset
	@echo "Running Klaus 6502 Functional Test (this will take a while)..."
	@PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f tests/run_klaus_test.sql
	@echo "Test complete"

reset: clean up
	@echo "Waiting for PostgreSQL to be ready..."
	@while ! pg_isready -h localhost -U postgres; do sleep 1; done
	@echo "Loading schema..."
	@for f in init/*.sql; do \
		PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f "$$f" > /dev/null; \
	done
	@echo "Loading Klaus test binary..."
	@PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f tests/load_klaus_test.sql

up:
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v
