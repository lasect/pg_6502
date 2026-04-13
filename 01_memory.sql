-- read one byte from memory. 0 for unmapped addresses for open bus.
CREATE OR REPLACE FUNCTION pg6502.mem_read(p_addr INT)
RETURNS INT AS $$
DECLARE
  v_val INT;
BEGIN
  SELECT val INTO v_val from pg6502.mem WHERE addr = p_addr;
  RETURN COALESCE(v_val, 0);
END;
$$ LANGUAGE plpgsql;

-- read 16 bit little-endian word
CREATE OR REPLACE FUNCTION pg6502.mem_read16(p_addr INT)
RETURNS INT AS $$
BEGIN
    RETURN pg6502.mem_read(p_addr) + (pg6502.mem_read(p_addr + 1) * 256);
END
$$ LANGUAGE plpgsql;

-- write one byte to memory
CREATE OR REPLACE FUNCTION pg6502.mem_write(p_addr INT, p_val INT)
RETURNS VOID AS $$
BEGIN
    p_val := p_val & 255; -- clamp for safety

    INSERT INTO pg6502.mem(addr, val)
    VALUES(p_addr, p_val)
    ON CONFLICT (addr) DO UPDATE SET val = EXCLUDED.val;
END
$$ LANGUAGE plpgsql;
