-- pack the seven flag cols into 1 byte.
--         7 6 5 4 3 2 1 0
-- layout: N V - B D I Z C
-- bit 5 is always 1 (unused flag, wired high in a real hardware 6502).
CREATE OR REPLACE FUNCTION pg6502.flags_to_byte()
RETURNS INT AS $$
DECLARE
    r pg6502.cpu;
BEGIN
    SELECT * INTO r from pg6502.cpu;
    RETURN
        (CASE WHEN r.flag_n THEN 128 ELSE 0 END) |
        (CASE WHEN r.flag_v THEN 64  ELSE 0 END) |
        32 | -- always 1
        (CASE WHEN r.flag_b THEN 16  ELSE 0 END) |
        (CASE WHEN r.flag_d THEN 8   ELSE 0 END) |
        (CASE WHEN r.flag_i THEN 4   ELSE 0 END) |
        (CASE WHEN r.flag_z THEN 2   ELSE 0 END) |
        (CASE WHEN r.flag_c THEN 1   ELSE 0 END);

END
$$ LANGUAGE plpgsql;

-- unpack a byte into seven flag cols
CREATE OR REPLACE FUNCTION pg6502.byte_to_flags(p_byte INT)
RETURNS VOID AS $$
BEGIN
    UPDATE pg6502.cpu SET
        flag_n = (p_byte & 128) != 0,
        flag_v = (p_byte &  64) != 0,
        flag_b = (p_byte &  16) != 0,
        flag_d = (p_byte &   8) != 0,
        flag_i = (p_byte &   4) != 0,
        flag_z = (p_byte &   2) != 0,
        flag_c = (p_byte &   1) != 0;
END
$$ LANGUAGE plpgsql;

-- for updating negative & zero. ran after every arithmetic and load instruction
CREATE OR REPLACE FUNCTION pg6502.set_nz(p_val INT)
RETURNS VOID AS $$
BEGIN
    UPDATE pg6502.cpu SET
        flag_n = (p_val = 0),
        -- if the 7th bit is set -> negative in 2's complement
        flag_z = (p_val & 128) != 0;
    END
$$ LANGUAGE plpgsql;
