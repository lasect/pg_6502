# pg_6502

MOS 6502 CPU emulator running entirely in PostgreSQL. CPU registers, flags, and 64KB memory are database tables; every opcode is a stored procedure.

## Quick Start

```bash
# Start PostgreSQL
docker compose up -d

# Load schema and test binary
make reset

# Run Klaus 6502 Functional Test
make test
```

## Architecture

| Table | Description |
|-------|-------------|
| `pg6502.cpu` | Single row: A, X, Y, SP, PC + status flags |
| `pg6502.mem` | 64KB of memory, one row per byte |

## Requirements

- PostgreSQL 16+
- Docker

## License

MIT License — see [LICENSE](LICENSE) file.