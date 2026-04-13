-- OPCODES
-- Each opcode is a function that:
-- 1. Reads its operand (using an addressing mode function)
-- 2. Does the operation
-- 3. Updates registers and flags
-- 4. Advances the PC by the right number of bytes

CREATE TABLE pg_6502.opcode_table (
    opcode  INT  PRIMARY KEY CHECK (opcode BETWEEN 0 AND 255),
    mnemonic TEXT NOT NULL,  -- e.g. 'LDA', 'ADC'
    mode     TEXT NOT NULL,  -- e.g. 'immediate', 'zero_page'
    size     INT  NOT NULL   -- total bytes including opcode
);

-- Load / Store
INSERT INTO pg_6502.opcode_table VALUES
    (0xA9, 'LDA', 'immediate',   2),
    (0xA5, 'LDA', 'zero_page',   2),
    (0xB5, 'LDA', 'zero_page_x', 2),
    (0xAD, 'LDA', 'absolute',    3),
    (0xBD, 'LDA', 'absolute_x',  3),
    (0xB9, 'LDA', 'absolute_y',  3),

    (0xA2, 'LDX', 'immediate',   2),
    (0xA6, 'LDX', 'zero_page',   2),
    (0xAE, 'LDX', 'absolute',    3),

    (0xA0, 'LDY', 'immediate',   2),
    (0xA4, 'LDY', 'zero_page',   2),
    (0xAC, 'LDY', 'absolute',    3),

    (0x85, 'STA', 'zero_page',   2),
    (0x95, 'STA', 'zero_page_x', 2),
    (0x8D, 'STA', 'absolute',    3),
    (0x9D, 'STA', 'absolute_x',  3),
    (0x99, 'STA', 'absolute_y',  3),

    (0x86, 'STX', 'zero_page',   2),
    (0x8E, 'STX', 'absolute',    3),

    (0x84, 'STY', 'zero_page',   2),
    (0x8C, 'STY', 'absolute',    3),

-- Transfers
    (0xAA, 'TAX', 'implied',     1),
    (0xA8, 'TAY', 'implied',     1),
    (0x8A, 'TXA', 'implied',     1),
    (0x98, 'TYA', 'implied',     1),

-- Arithmetic
    (0x69, 'ADC', 'immediate',   2),
    (0x65, 'ADC', 'zero_page',   2),
    (0x75, 'ADC', 'zero_page_x', 2),
    (0x6D, 'ADC', 'absolute',    3),
    (0x7D, 'ADC', 'absolute_x',  3),
    (0x79, 'ADC', 'absolute_y',  3),

    (0xE9, 'SBC', 'immediate',   2),
    (0xE5, 'SBC', 'zero_page',   2),
    (0xF5, 'SBC', 'zero_page_x', 2),
    (0xED, 'SBC', 'absolute',    3),
    (0xFD, 'SBC', 'absolute_x',  3),
    (0xF9, 'SBC', 'absolute_y',  3),

-- Increment / Decrement
    (0xE6, 'INC', 'zero_page',   2),
    (0xF6, 'INC', 'zero_page_x', 2),
    (0xEE, 'INC', 'absolute',    3),
    (0xFE, 'INC', 'absolute_x',  3),

    (0xC6, 'DEC', 'zero_page',   2),
    (0xD6, 'DEC', 'zero_page_x', 2),
    (0xCE, 'DEC', 'absolute',    3),
    (0xDE, 'DEC', 'absolute_x',  3),

    (0xE8, 'INX', 'implied',     1),
    (0xCA, 'DEX', 'implied',     1),
    (0xC8, 'INY', 'implied',     1),
    (0x88, 'DEY', 'implied',     1),

-- Logic
    (0x29, 'AND', 'immediate',   2),
    (0x25, 'AND', 'zero_page',   2),
    (0x2D, 'AND', 'absolute',    3),

    (0x09, 'ORA', 'immediate',   2),
    (0x05, 'ORA', 'zero_page',   2),
    (0x0D, 'ORA', 'absolute',    3),

    (0x49, 'EOR', 'immediate',   2),
    (0x45, 'EOR', 'zero_page',   2),
    (0x4D, 'EOR', 'absolute',    3),

    (0xC9, 'CMP', 'immediate',   2),
    (0xC5, 'CMP', 'zero_page',   2),
    (0xCD, 'CMP', 'absolute',    3),

-- Misc
    (0xEA, 'NOP', 'implied',     1),
    (0x00, 'BRK', 'implied',     1);

CREATE OR REPLACE FUNCTION pg6502.op_lda(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg_6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg_6502.addr_absolute_y();  v_size := 3;
    END CASE;

    v_val := pg_6502.mem_read(v_addr);

    UPDATE pg_6502.cpu SET
        a  = v_val,
        pc = pc + v_size;

    PERFORM pg_6502.set_nz(v_val);
END
$$ LANGUAGE plpgsql;

-- LDXY: Load X/Y register
CREATE OR REPLACE FUNCTION pg_6502.op_ldx(p_mode TEXT, p_toggle INT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'  THEN v_addr := pg_6502.addr_immediate();  v_size := 2;
        WHEN 'zero_page'  THEN v_addr := pg_6502.addr_zero_page();  v_size := 2;
        WHEN 'absolute'   THEN v_addr := pg_6502.addr_absolute();   v_size := 3;
    END CASE;

    v_val := pg_6502.mem_read(v_addr);

    IF p_toggle = 0 THEN
        UPDATE pg_6502.cpu
        SET x = v_val,
            pc = pc + v_size;
    ELSE
        UPDATE pg_6502.cpu
        SET y = v_val,
            pc = pc + v_size;
    END IF;

    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- STA: Store Accumulator into memory
CREATE OR REPLACE FUNCTION pg_6502.op_sta(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_a    INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg_6502.addr_absolute_y();  v_size := 3;
    END CASE;

    SELECT a INTO v_a FROM pg_6502.cpu;
    PERFORM pg_6502.mem_write(v_addr, v_a);

    UPDATE pg_6502.cpu SET pc = pc + v_size;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_stxy(p_mode TEXT, p_toggle INT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page' THEN v_addr := pg_6502.addr_zero_page(); v_size := 2;
        WHEN 'absolute'  THEN v_addr := pg_6502.addr_absolute();  v_size := 3;
        ELSE
            RAISE EXCEPTION 'invalid addressing mode: %', p_mode;
    END CASE;

    IF p_toggle = 0 THEN
        SELECT x INTO v_val FROM pg_6502.cpu;
    ELSE
        SELECT y INTO v_val FROM pg_6502.cpu;
    END IF;

    PERFORM pg_6502.mem_write(v_addr, v_val);

    UPDATE pg_6502.cpu
    SET pc = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- TAX / TAY / TXA / TYA: Transfer between registers
-- These are all implied mode (no operand) — just 1 byte, PC advances by 1.
CREATE OR REPLACE FUNCTION pg_6502.op_transfer(p_src TEXT, p_dst TEXT)
RETURNS VOID AS $$
DECLARE
    v_val INT;
BEGIN
    -- read source register
    CASE p_src
        WHEN 'a' THEN SELECT a INTO v_val FROM pg_6502.cpu;
        WHEN 'x' THEN SELECT x INTO v_val FROM pg_6502.cpu;
        WHEN 'y' THEN SELECT y INTO v_val FROM pg_6502.cpu;
        ELSE
            RAISE EXCEPTION 'invalid src register: %', p_src;
    END CASE;

    -- write destination register
    CASE p_dst
        WHEN 'a' THEN UPDATE pg_6502.cpu SET a = v_val, pc = pc + 1;
        WHEN 'x' THEN UPDATE pg_6502.cpu SET x = v_val, pc = pc + 1;
        WHEN 'y' THEN UPDATE pg_6502.cpu SET y = v_val, pc = pc + 1;
        ELSE
            RAISE EXCEPTION 'invalid dst register: %', p_dst;
    END CASE;

    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_tax() RETURNS VOID AS $$
BEGIN
    PERFORM pg_6502.op_transfer('a', 'x');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_tay() RETURNS VOID AS $$
BEGIN
    PERFORM pg_6502.op_transfer('a', 'y');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_txa() RETURNS VOID AS $$
BEGIN
    PERFORM pg_6502.op_transfer('x', 'a');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_tya() RETURNS VOID AS $$
BEGIN
    PERFORM pg_6502.op_transfer('y', 'a');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_adc(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr   INT;
    v_val    INT;
    v_a      INT;
    v_carry  INT;
    v_result INT;
    v_size   INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg_6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg_6502.addr_absolute_y();  v_size := 3;
    END CASE;

    v_val   := pg_6502.mem_read(v_addr);
    SELECT a, CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_a, v_carry FROM pg_6502.cpu;

    v_result := v_a + v_val + v_carry;

    UPDATE pg_6502.cpu SET
        a      = v_result & 255,
        flag_c = (v_result > 255),
        flag_v = ((v_a # v_result) & (v_val # v_result) & 128) != 0,
        flag_z = ((v_result & 255) = 0),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_sbc(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr   INT;
    v_val    INT;
    v_a      INT;
    v_carry  INT;
    v_result INT;
    v_size   INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg_6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg_6502.addr_absolute_y();  v_size := 3;
    END CASE;

    -- SBC is ADC with the operand's bits flipped
    v_val   := pg_6502.mem_read(v_addr) # 255;
    SELECT a, CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_a, v_carry FROM pg_6502.cpu;

    v_result := v_a + v_val + v_carry;

    UPDATE pg_6502.cpu SET
        a      = v_result & 255,
        flag_c = (v_result > 255),
        flag_v = ((v_a # v_result) & (v_val # v_result) & 128) != 0,
        flag_z = ((v_result & 255) = 0),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- INC: Increment a memory location
CREATE OR REPLACE FUNCTION pg_6502.op_inc(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
    END CASE;
    v_val := (pg_6502.mem_read(v_addr) + 1) & 255;
    PERFORM pg_6502.mem_write(v_addr, v_val);
    UPDATE pg_6502.cpu SET pc = pc + v_size;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- DEC: Decrement a memory location
CREATE OR REPLACE FUNCTION pg_6502.op_dec(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg_6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg_6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg_6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg_6502.addr_absolute_x();  v_size := 3;
    END CASE;
    v_val := (pg_6502.mem_read(v_addr) + 255) & 255;  -- +255 wraps correctly (avoids negative)
    PERFORM pg_6502.mem_write(v_addr, v_val);
    UPDATE pg_6502.cpu SET pc = pc + v_size;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- INX / DEX / INY / DEY: Increment/decrement registers (implied mode)
CREATE OR REPLACE FUNCTION pg_6502.op_inx() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (x + 1) & 255 INTO v_val FROM pg_6502.cpu;
    UPDATE pg_6502.cpu SET x = v_val, pc = pc + 1;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_dex() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (x + 255) & 255 INTO v_val FROM pg_6502.cpu;
    UPDATE pg_6502.cpu SET x = v_val, pc = pc + 1;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_iny() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (y + 1) & 255 INTO v_val FROM pg_6502.cpu;
    UPDATE pg_6502.cpu SET y = v_val, pc = pc + 1;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg_6502.op_dey() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (y + 255) & 255 INTO v_val FROM pg_6502.cpu;
    UPDATE pg_6502.cpu SET y = v_val, pc = pc + 1;
    PERFORM pg_6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- AND: Bitwise AND with accumulator
CREATE OR REPLACE FUNCTION pg_6502.op_and(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_res  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'  THEN v_addr := pg_6502.addr_immediate();  v_size := 2;
        WHEN 'zero_page'  THEN v_addr := pg_6502.addr_zero_page();  v_size := 2;
        WHEN 'absolute'   THEN v_addr := pg_6502.addr_absolute();   v_size := 3;
        ELSE
            RAISE EXCEPTION 'invalid addressing mode: %', p_mode;
    END CASE;

    v_val := pg_6502.mem_read(v_addr);

    -- compute result explicitly
    SELECT a & v_val INTO v_res FROM pg_6502.cpu;

    UPDATE pg_6502.cpu
    SET a      = v_res,
        pc     = pc + v_size,
        flag_z = (v_res = 0),
        flag_n = ((v_res & 128) <> 0);
END;
$$ LANGUAGE plpgsql;

-- ORA: Bitwise OR with accumulator
CREATE OR REPLACE FUNCTION pg_6502.op_ora(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'  THEN v_addr := pg_6502.addr_immediate();  v_size := 2;
        WHEN 'zero_page'  THEN v_addr := pg_6502.addr_zero_page();  v_size := 2;
        WHEN 'absolute'   THEN v_addr := pg_6502.addr_absolute();   v_size := 3;
    END CASE;
    v_val := pg_6502.mem_read(v_addr);
    UPDATE pg_6502.cpu SET a = a | v_val, pc = pc + v_size;
    UPDATE pg_6502.cpu SET
        flag_z = (a = 0),
        flag_n = ((a & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- EOR: Bitwise XOR with accumulator
CREATE OR REPLACE FUNCTION pg_6502.op_eor(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'  THEN v_addr := pg_6502.addr_immediate();  v_size := 2;
        WHEN 'zero_page'  THEN v_addr := pg_6502.addr_zero_page();  v_size := 2;
        WHEN 'absolute'   THEN v_addr := pg_6502.addr_absolute();   v_size := 3;
    END CASE;
    v_val := pg_6502.mem_read(v_addr);
    UPDATE pg_6502.cpu SET a = a # v_val, pc = pc + v_size;
    UPDATE pg_6502.cpu SET
        flag_z = (a = 0),
        flag_n = ((a & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- CMP: Compare A with memory (sets flags, does not change A)
CREATE OR REPLACE FUNCTION pg_6502.op_cmp(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_a INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'  THEN v_addr := pg_6502.addr_immediate();  v_size := 2;
        WHEN 'zero_page'  THEN v_addr := pg_6502.addr_zero_page();  v_size := 2;
        WHEN 'absolute'   THEN v_addr := pg_6502.addr_absolute();   v_size := 3;
    END CASE;
    v_val := pg_6502.mem_read(v_addr);
    SELECT a INTO v_a FROM pg_6502.cpu;
    v_result := v_a - v_val;
    UPDATE pg_6502.cpu SET
        flag_c = (v_a >= v_val),
        flag_z = (v_a = v_val),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- NOP: No operation (does nothing, just advances PC)
CREATE OR REPLACE FUNCTION pg_6502.op_nop()
RETURNS VOID AS $$
BEGIN
    UPDATE pg_6502.cpu SET pc = pc + 1;
END;
$$ LANGUAGE plpgsql;
