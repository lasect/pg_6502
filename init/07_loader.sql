-- Load a program from a bytea value into memory starting at p_start.
-- Also writes the reset vector at $FFFC pointing to p_start.
CREATE OR REPLACE FUNCTION pg6502.load_program(p_bytes BYTEA, p_start INT DEFAULT 1536)
RETURNS VOID AS $$
DECLARE
    i INT;
BEGIN
    -- Clear existing memory
    DELETE FROM pg6502.mem;

    -- Write each byte
    FOR i IN 0 .. length(p_bytes) - 1 LOOP
        PERFORM pg6502.mem_write(p_start + i, get_byte(p_bytes, i));
    END LOOP;

    -- Write reset vector (little-endian)
    PERFORM pg6502.mem_write(65532, p_start & 255);
    PERFORM pg6502.mem_write(65533, (p_start >> 8) & 255);
END;
$$ LANGUAGE plpgsql;
