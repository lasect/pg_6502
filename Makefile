.PHONY: test up down clean

test: up
	@echo "Waiting for PostgreSQL to be ready..."
	@sleep 5
	@echo "Loading schema..."
	@for f in init/*.sql; do \
		echo "Loading $$f"; \
		PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f "$$f" > /dev/null; \
	done
	@echo "Resetting CPU state..."
	@PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -c "DELETE FROM pg6502.mem; UPDATE pg6502.cpu SET pc = 1024;"
	@echo "Loading Klaus test binary..."
	@PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f tests/load_klaus_test.sql
	@echo "Running Klaus 6502 Functional Test (this will take a while)..."
	@PGPASSWORD=postgres psql -h localhost -U postgres -d postgres -f tests/run_klaus_test.sql
	@echo "Test complete"

up:
	docker compose up -d

down:
	docker compose down

clean:
	docker compose down -v
	rm -f tests/6502_functional_test.txt