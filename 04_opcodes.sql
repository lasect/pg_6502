-- OPCODES
-- Each opcode is a function that:
-- 1. Reads its operand (using an addressing mode function)
-- 2. Does the operation
-- 3. Updates registers and flags
-- 4. Advances the PC by the right number of bytes

CREATE TABLE pg6502.opcode_table (
    opcode  INT  PRIMARY KEY CHECK (opcode BETWEEN 0 AND 255),
    mnemonic TEXT NOT NULL,  -- e.g. 'LDA', 'ADC'
    mode     TEXT NOT NULL,  -- e.g. 'immediate', 'zero_page'
    size     INT  NOT NULL   -- total bytes including opcode
);

-- Load / Store
INSERT INTO pg6502.opcode_table VALUES
    (0xA9, 'LDA', 'immediate',   2),
    (0xA5, 'LDA', 'zero_page',   2),
    (0xB5, 'LDA', 'zero_page_x', 2),
    (0xAD, 'LDA', 'absolute',    3),
    (0xBD, 'LDA', 'absolute_x',  3),
    (0xB9, 'LDA', 'absolute_y',  3),
    (0xA1, 'LDA', 'indirect_x',  2),
    (0xB1, 'LDA', 'indirect_y',  2),

    (0xA2, 'LDX', 'immediate',   2),
    (0xA6, 'LDX', 'zero_page',   2),
    (0xB6, 'LDX', 'zero_page_y', 2),
    (0xAE, 'LDX', 'absolute',    3),
    (0xBE, 'LDX', 'absolute_y',  3),

    (0xA0, 'LDY', 'immediate',   2),
    (0xA4, 'LDY', 'zero_page',   2),
    (0xB4, 'LDY', 'zero_page_x', 2),
    (0xAC, 'LDY', 'absolute',    3),
    (0xBC, 'LDY', 'absolute_x',  3),

    (0x85, 'STA', 'zero_page',   2),
    (0x95, 'STA', 'zero_page_x', 2),
    (0x8D, 'STA', 'absolute',    3),
    (0x9D, 'STA', 'absolute_x',  3),
    (0x99, 'STA', 'absolute_y',  3),
    (0x81, 'STA', 'indirect_x',  2),
    (0x91, 'STA', 'indirect_y',  2),

    (0x86, 'STX', 'zero_page',   2),
    (0x96, 'STX', 'zero_page_y', 2),
    (0x8E, 'STX', 'absolute',    3),

    (0x84, 'STY', 'zero_page',   2),
    (0x94, 'STY', 'zero_page_x', 2),
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
    (0x61, 'ADC', 'indirect_x',  2),
    (0x71, 'ADC', 'indirect_y',  2),

    (0xE9, 'SBC', 'immediate',   2),
    (0xE5, 'SBC', 'zero_page',   2),
    (0xF5, 'SBC', 'zero_page_x', 2),
    (0xED, 'SBC', 'absolute',    3),
    (0xFD, 'SBC', 'absolute_x',  3),
    (0xF9, 'SBC', 'absolute_y',  3),
    (0xE1, 'SBC', 'indirect_x',  2),
    (0xF1, 'SBC', 'indirect_y',  2),

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
    (0x35, 'AND', 'zero_page_x', 2),
    (0x2D, 'AND', 'absolute',    3),
    (0x3D, 'AND', 'absolute_x',  3),
    (0x39, 'AND', 'absolute_y',  3),
    (0x21, 'AND', 'indirect_x',  2),
    (0x31, 'AND', 'indirect_y',  2),

    (0x09, 'ORA', 'immediate',   2),
    (0x05, 'ORA', 'zero_page',   2),
    (0x15, 'ORA', 'zero_page_x', 2),
    (0x0D, 'ORA', 'absolute',    3),
    (0x1D, 'ORA', 'absolute_x',  3),
    (0x19, 'ORA', 'absolute_y',  3),
    (0x01, 'ORA', 'indirect_x',  2),
    (0x11, 'ORA', 'indirect_y',  2),

    (0x49, 'EOR', 'immediate',   2),
    (0x45, 'EOR', 'zero_page',   2),
    (0x55, 'EOR', 'zero_page_x', 2),
    (0x4D, 'EOR', 'absolute',    3),
    (0x5D, 'EOR', 'absolute_x',  3),
    (0x59, 'EOR', 'absolute_y',  3),
    (0x41, 'EOR', 'indirect_x',  2),
    (0x51, 'EOR', 'indirect_y',  2),

    (0xC9, 'CMP', 'immediate',   2),
    (0xC5, 'CMP', 'zero_page',   2),
    (0xD5, 'CMP', 'zero_page_x', 2),
    (0xCD, 'CMP', 'absolute',    3),
    (0xDD, 'CMP', 'absolute_x',  3),
    (0xD9, 'CMP', 'absolute_y',  3),
    (0xC1, 'CMP', 'indirect_x',  2),
    (0xD1, 'CMP', 'indirect_y',  2),

-- Compare X
    (0xE0, 'CPX', 'immediate',   2),
    (0xE4, 'CPX', 'zero_page',   2),
    (0xEC, 'CPX', 'absolute',    3),

-- Compare Y
    (0xC0, 'CPY', 'immediate',   2),
    (0xC4, 'CPY', 'zero_page',   2),
    (0xCC, 'CPY', 'absolute',    3),

-- BIT: Bit test (loads memory into A, tests bits against flags)
    (0x24, 'BIT', 'zero_page',   2),
    (0x2C, 'BIT', 'absolute',    3),

-- ASL: Arithmetic Shift Left
    (0x0A, 'ASL', 'accumulator', 1),
    (0x06, 'ASL', 'zero_page',   2),
    (0x16, 'ASL', 'zero_page_x', 2),
    (0x0E, 'ASL', 'absolute',    3),
    (0x1E, 'ASL', 'absolute_x',  3),

-- LSR: Logical Shift Right
    (0x4A, 'LSR', 'accumulator', 1),
    (0x46, 'LSR', 'zero_page',   2),
    (0x56, 'LSR', 'zero_page_x', 2),
    (0x4E, 'LSR', 'absolute',    3),
    (0x5E, 'LSR', 'absolute_x',  3),

-- ROL: Rotate Left
    (0x2A, 'ROL', 'accumulator', 1),
    (0x26, 'ROL', 'zero_page',   2),
    (0x36, 'ROL', 'zero_page_x', 2),
    (0x2E, 'ROL', 'absolute',    3),
    (0x3E, 'ROL', 'absolute_x',  3),

-- ROR: Rotate Right
    (0x6A, 'ROR', 'accumulator', 1),
    (0x66, 'ROR', 'zero_page',   2),
    (0x76, 'ROR', 'zero_page_x', 2),
    (0x6E, 'ROR', 'absolute',    3),
    (0x7E, 'ROR', 'absolute_x',  3),

-- Misc
    (0xEA, 'NOP', 'implied',     1),
    (0x00, 'BRK', 'implied',     1),

-- Jumps
    (0x4C, 'JMP', 'absolute',    3),
    (0x6C, 'JMP', 'indirect',    3),

-- Branches
    (0x90, 'BCC', 'relative',    2),
    (0xB0, 'BCS', 'relative',    2),
    (0xF0, 'BEQ', 'relative',    2),
    (0xD0, 'BNE', 'relative',    2),
    (0x50, 'BVC', 'relative',    2),
    (0x70, 'BVS', 'relative',    2),
    (0x10, 'BPL', 'relative',    2),
    (0x30, 'BMI', 'relative',    2),

-- Stack
    (0x48, 'PHA', 'implied',     1),
    (0x68, 'PLA', 'implied',     1),
    (0x08, 'PHP', 'implied',     1),
    (0x28, 'PLP', 'implied',     1),
    (0x9A, 'TXS', 'implied',     1),
    (0xBA, 'TSX', 'implied',     1);

CREATE OR REPLACE FUNCTION pg6502.op_lda(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;

    v_val := pg6502.mem_read(v_addr);

    UPDATE pg6502.cpu SET
        a  = v_val,
        pc = pc + v_size;

    PERFORM pg6502.set_nz(v_val);
END
$$ LANGUAGE plpgsql;

-- LDXY: Load X/Y register
CREATE OR REPLACE FUNCTION pg6502.op_ldxy(p_mode TEXT, p_toggle INT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_y' THEN v_addr := pg6502.addr_zero_page_y(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
    END CASE;

    v_val := pg6502.mem_read(v_addr);

    IF p_toggle = 0 THEN
        UPDATE pg6502.cpu
        SET x = v_val,
            pc = pc + v_size;
    ELSE
        UPDATE pg6502.cpu
        SET y = v_val,
            pc = pc + v_size;
    END IF;

    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- STA: Store Accumulator into memory
CREATE OR REPLACE FUNCTION pg6502.op_sta(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_a    INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();      v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();      v_size := 2;
    END CASE;

    SELECT a INTO v_a FROM pg6502.cpu;
    PERFORM pg6502.mem_write(v_addr, v_a);

    UPDATE pg6502.cpu SET pc = pc + v_size;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_stxy(p_mode TEXT, p_toggle INT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page' THEN v_addr := pg6502.addr_zero_page(); v_size := 2;
        WHEN 'absolute'  THEN v_addr := pg6502.addr_absolute();  v_size := 3;
        ELSE
            RAISE EXCEPTION 'invalid addressing mode: %', p_mode;
    END CASE;

    IF p_toggle = 0 THEN
        SELECT x INTO v_val FROM pg6502.cpu;
    ELSE
        SELECT y INTO v_val FROM pg6502.cpu;
    END IF;

    PERFORM pg6502.mem_write(v_addr, v_val);

    UPDATE pg6502.cpu
    SET pc = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- TAX / TAY / TXA / TYA: Transfer between registers
-- These are all implied mode (no operand) — just 1 byte, PC advances by 1.
CREATE OR REPLACE FUNCTION pg6502.op_transfer(p_src TEXT, p_dst TEXT)
RETURNS VOID AS $$
DECLARE
    v_val INT;
BEGIN
    -- read source register
    CASE p_src
        WHEN 'a' THEN SELECT a INTO v_val FROM pg6502.cpu;
        WHEN 'x' THEN SELECT x INTO v_val FROM pg6502.cpu;
        WHEN 'y' THEN SELECT y INTO v_val FROM pg6502.cpu;
        ELSE
            RAISE EXCEPTION 'invalid src register: %', p_src;
    END CASE;

    -- write destination register
    CASE p_dst
        WHEN 'a' THEN UPDATE pg6502.cpu SET a = v_val, pc = pc + 1;
        WHEN 'x' THEN UPDATE pg6502.cpu SET x = v_val, pc = pc + 1;
        WHEN 'y' THEN UPDATE pg6502.cpu SET y = v_val, pc = pc + 1;
        ELSE
            RAISE EXCEPTION 'invalid dst register: %', p_dst;
    END CASE;

    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_tax() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_transfer('a', 'x');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_tay() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_transfer('a', 'y');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_txa() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_transfer('x', 'a');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_tya() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_transfer('y', 'a');
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_adc(p_mode TEXT)
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
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;

    v_val   := pg6502.mem_read(v_addr);
    SELECT a, CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_a, v_carry FROM pg6502.cpu;

    v_result := v_a + v_val + v_carry;

    UPDATE pg6502.cpu SET
        a      = v_result & 255,
        flag_c = (v_result > 255),
        flag_v = ((v_a # v_result) & (v_val # v_result) & 128) != 0,
        flag_z = ((v_result & 255) = 0),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_sbc(p_mode TEXT)
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
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;

    -- SBC is ADC with the operand's bits flipped
    v_val   := pg6502.mem_read(v_addr) # 255;
    SELECT a, CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_a, v_carry FROM pg6502.cpu;

    v_result := v_a + v_val + v_carry;

    UPDATE pg6502.cpu SET
        a      = v_result & 255,
        flag_c = (v_result > 255),
        flag_v = ((v_a # v_result) & (v_val # v_result) & 128) != 0,
        flag_z = ((v_result & 255) = 0),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- INC: Increment a memory location
CREATE OR REPLACE FUNCTION pg6502.op_inc(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    v_val := (pg6502.mem_read(v_addr) + 1) & 255;
    PERFORM pg6502.mem_write(v_addr, v_val);
    UPDATE pg6502.cpu SET pc = pc + v_size;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- DEC: Decrement a memory location
CREATE OR REPLACE FUNCTION pg6502.op_dec(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();     v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    v_val := (pg6502.mem_read(v_addr) + 255) & 255;  -- +255 wraps correctly (avoids negative)
    PERFORM pg6502.mem_write(v_addr, v_val);
    UPDATE pg6502.cpu SET pc = pc + v_size;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- INX / DEX / INY / DEY: Increment/decrement registers (implied mode)
CREATE OR REPLACE FUNCTION pg6502.op_inx() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (x + 1) & 255 INTO v_val FROM pg6502.cpu;
    UPDATE pg6502.cpu SET x = v_val, pc = pc + 1;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_dex() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (x + 255) & 255 INTO v_val FROM pg6502.cpu;
    UPDATE pg6502.cpu SET x = v_val, pc = pc + 1;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_iny() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (y + 1) & 255 INTO v_val FROM pg6502.cpu;
    UPDATE pg6502.cpu SET y = v_val, pc = pc + 1;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_dey() RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    SELECT (y + 255) & 255 INTO v_val FROM pg6502.cpu;
    UPDATE pg6502.cpu SET y = v_val, pc = pc + 1;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

-- AND: Bitwise AND with accumulator
CREATE OR REPLACE FUNCTION pg6502.op_and(p_mode TEXT)
RETURNS VOID AS $$
DECLARE
    v_addr INT;
    v_val  INT;
    v_res  INT;
    v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;

    v_val := pg6502.mem_read(v_addr);

    -- compute result explicitly
    SELECT a & v_val INTO v_res FROM pg6502.cpu;

    UPDATE pg6502.cpu
    SET a      = v_res,
        pc     = pc + v_size,
        flag_z = (v_res = 0),
        flag_n = ((v_res & 128) <> 0);
END;
$$ LANGUAGE plpgsql;

-- ORA: Bitwise OR with accumulator
CREATE OR REPLACE FUNCTION pg6502.op_ora(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    UPDATE pg6502.cpu SET a = a | v_val, pc = pc + v_size;
    UPDATE pg6502.cpu SET
        flag_z = (a = 0),
        flag_n = ((a & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- EOR: Bitwise XOR with accumulator
CREATE OR REPLACE FUNCTION pg6502.op_eor(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    UPDATE pg6502.cpu SET a = a # v_val, pc = pc + v_size;
    UPDATE pg6502.cpu SET
        flag_z = (a = 0),
        flag_n = ((a & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- CMP: Compare A with memory (sets flags, does not change A)
CREATE OR REPLACE FUNCTION pg6502.op_cmp(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_a INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
        WHEN 'absolute_y'  THEN v_addr := pg6502.addr_absolute_y();  v_size := 3;
        WHEN 'indirect_x'  THEN v_addr := pg6502.addr_indirect_x();       v_size := 2;
        WHEN 'indirect_y'  THEN v_addr := pg6502.addr_indirect_y();       v_size := 2;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    SELECT a INTO v_a FROM pg6502.cpu;
    v_result := v_a - v_val;
    UPDATE pg6502.cpu SET
        flag_c = (v_a >= v_val),
        flag_z = (v_a = v_val),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- CPX: Compare X with memory
CREATE OR REPLACE FUNCTION pg6502.op_cpx(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_x INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    SELECT x INTO v_x FROM pg6502.cpu;
    v_result := v_x - v_val;
    UPDATE pg6502.cpu SET
        flag_c = (v_x >= v_val),
        flag_z = (v_x = v_val),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- CPY: Compare Y with memory
CREATE OR REPLACE FUNCTION pg6502.op_cpy(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_y INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'immediate'   THEN v_addr := pg6502.addr_immediate();   v_size := 2;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    SELECT y INTO v_y FROM pg6502.cpu;
    v_result := v_y - v_val;
    UPDATE pg6502.cpu SET
        flag_c = (v_y >= v_val),
        flag_z = (v_y = v_val),
        flag_n = ((v_result & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- BIT: Bit test - loads value, tests bits against flags, doesn't change A (on real 6502 A is affected but flags are set from memory)
CREATE OR REPLACE FUNCTION pg6502.op_bit(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_a INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'zero_page' THEN v_addr := pg6502.addr_zero_page(); v_size := 2;
        WHEN 'absolute'  THEN v_addr := pg6502.addr_absolute();  v_size := 3;
    END CASE;
    v_val := pg6502.mem_read(v_addr);
    SELECT a INTO v_a FROM pg6502.cpu;
    UPDATE pg6502.cpu SET
        flag_z = ((v_a & v_val) = 0),
        flag_v = ((v_val & 64) != 0),
        flag_n = ((v_val & 128) != 0),
        pc     = pc + v_size;
END;
$$ LANGUAGE plpgsql;

-- ASL: Arithmetic Shift Left
CREATE OR REPLACE FUNCTION pg6502.op_asl(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'accumulator' THEN
            SELECT a INTO v_val FROM pg6502.cpu;
            v_result := (v_val * 2) & 255;
            UPDATE pg6502.cpu SET a = v_result, pc = pc + 1;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    
    IF p_mode != 'accumulator' THEN
        v_val := pg6502.mem_read(v_addr);
        v_result := (v_val * 2) & 255;
        PERFORM pg6502.mem_write(v_addr, v_result);
        UPDATE pg6502.cpu SET pc = pc + v_size;
    END IF;
    
    UPDATE pg6502.cpu SET
        flag_c = (v_val >= 128),
        flag_z = (v_result = 0),
        flag_n = ((v_result & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- LSR: Logical Shift Right
CREATE OR REPLACE FUNCTION pg6502.op_lsr(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_result INT; v_size INT;
BEGIN
    CASE p_mode
        WHEN 'accumulator' THEN
            SELECT a INTO v_val FROM pg6502.cpu;
            v_result := v_val >> 1;
            UPDATE pg6502.cpu SET a = v_result, pc = pc + 1;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    
    IF p_mode != 'accumulator' THEN
        v_val := pg6502.mem_read(v_addr);
        v_result := v_val >> 1;
        PERFORM pg6502.mem_write(v_addr, v_result);
        UPDATE pg6502.cpu SET pc = pc + v_size;
    END IF;
    
    UPDATE pg6502.cpu SET
        flag_c = ((v_val & 1) = 1),
        flag_z = (v_result = 0),
        flag_n = FALSE;
END;
$$ LANGUAGE plpgsql;

-- ROL: Rotate Left
CREATE OR REPLACE FUNCTION pg6502.op_rol(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_result INT; v_carry INT; v_size INT;
BEGIN
    SELECT CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_carry FROM pg6502.cpu;
    
    CASE p_mode
        WHEN 'accumulator' THEN
            SELECT a INTO v_val FROM pg6502.cpu;
            v_result := ((v_val * 2) | v_carry) & 255;
            UPDATE pg6502.cpu SET a = v_result, pc = pc + 1;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    
    IF p_mode != 'accumulator' THEN
        v_val := pg6502.mem_read(v_addr);
        v_result := ((v_val * 2) | v_carry) & 255;
        PERFORM pg6502.mem_write(v_addr, v_result);
        UPDATE pg6502.cpu SET pc = pc + v_size;
    END IF;
    
    UPDATE pg6502.cpu SET
        flag_c = (v_val >= 128),
        flag_z = (v_result = 0),
        flag_n = ((v_result & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- ROR: Rotate Right
CREATE OR REPLACE FUNCTION pg6502.op_ror(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT; v_val INT; v_result INT; v_carry INT; v_size INT;
BEGIN
    SELECT CASE WHEN flag_c THEN 1 ELSE 0 END INTO v_carry FROM pg6502.cpu;
    
    CASE p_mode
        WHEN 'accumulator' THEN
            SELECT a INTO v_val FROM pg6502.cpu;
            v_result := (v_val >> 1) | (v_carry * 128);
            UPDATE pg6502.cpu SET a = v_result, pc = pc + 1;
        WHEN 'zero_page'   THEN v_addr := pg6502.addr_zero_page();   v_size := 2;
        WHEN 'zero_page_x' THEN v_addr := pg6502.addr_zero_page_x(); v_size := 2;
        WHEN 'absolute'    THEN v_addr := pg6502.addr_absolute();    v_size := 3;
        WHEN 'absolute_x'  THEN v_addr := pg6502.addr_absolute_x();  v_size := 3;
    END CASE;
    
    IF p_mode != 'accumulator' THEN
        v_val := pg6502.mem_read(v_addr);
        v_result := (v_val >> 1) | (v_carry * 128);
        PERFORM pg6502.mem_write(v_addr, v_result);
        UPDATE pg6502.cpu SET pc = pc + v_size;
    END IF;
    
    UPDATE pg6502.cpu SET
        flag_c = ((v_val & 1) = 1),
        flag_z = (v_result = 0),
        flag_n = ((v_result & 128) != 0);
END;
$$ LANGUAGE plpgsql;

-- NOP: No operation (does nothing, just advances PC)
CREATE OR REPLACE FUNCTION pg6502.op_nop()
RETURNS VOID AS $$
BEGIN
    UPDATE pg6502.cpu SET pc = pc + 1;
END;
$$ LANGUAGE plpgsql;

-- JMP: Jump to address
CREATE OR REPLACE FUNCTION pg6502.op_jmp(p_mode TEXT)
RETURNS VOID AS $$
DECLARE v_addr INT;
BEGIN
    CASE p_mode
        WHEN 'absolute'  THEN v_addr := pg6502.addr_absolute();
        WHEN 'indirect'  THEN v_addr := pg6502.addr_indirect();
    END CASE;
    UPDATE pg6502.cpu SET pc = v_addr;
END;
$$ LANGUAGE plpgsql;

-- Branch instructions
CREATE OR REPLACE FUNCTION pg6502.op_branch(p_condition BOOLEAN)
RETURNS VOID AS $$
DECLARE v_target INT;
BEGIN
    IF p_condition THEN
        v_target := pg6502.addr_relative();
        UPDATE pg6502.cpu SET pc = v_target;
    ELSE
        UPDATE pg6502.cpu SET pc = pc + 2;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bcc() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_c FROM pg6502.cpu) = FALSE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bcs() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_c FROM pg6502.cpu) = TRUE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_beq() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_z FROM pg6502.cpu) = TRUE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bne() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_z FROM pg6502.cpu) = FALSE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bvc() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_v FROM pg6502.cpu) = FALSE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bvs() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_v FROM pg6502.cpu) = TRUE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bpl() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_n FROM pg6502.cpu) = FALSE);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_bmi() RETURNS VOID AS $$
BEGIN
    PERFORM pg6502.op_branch((SELECT flag_n FROM pg6502.cpu) = TRUE);
END;
$$ LANGUAGE plpgsql;

-- Stack operations
CREATE OR REPLACE FUNCTION pg6502.op_pha()
RETURNS VOID AS $$
DECLARE v_a INT;
BEGIN
    SELECT a INTO v_a FROM pg6502.cpu;
    PERFORM pg6502.stack_push(v_a);
    UPDATE pg6502.cpu SET pc = pc + 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_pla()
RETURNS VOID AS $$
DECLARE v_val INT;
BEGIN
    v_val := pg6502.stack_pop();
    UPDATE pg6502.cpu SET a = v_val, pc = pc + 1;
    PERFORM pg6502.set_nz(v_val);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_php()
RETURNS VOID AS $$
DECLARE v_flags INT;
BEGIN
    v_flags := pg6502.flags_to_byte();
    PERFORM pg6502.stack_push(v_flags);
    UPDATE pg6502.cpu SET pc = pc + 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_plp()
RETURNS VOID AS $$
DECLARE v_flags INT;
BEGIN
    v_flags := pg6502.stack_pop();
    PERFORM pg6502.byte_to_flags(v_flags);
    UPDATE pg6502.cpu SET pc = pc + 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_txs()
RETURNS VOID AS $$
DECLARE v_x INT;
BEGIN
    SELECT x INTO v_x FROM pg6502.cpu;
    UPDATE pg6502.cpu SET sp = v_x, pc = pc + 1;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.op_tsx()
RETURNS VOID AS $$
DECLARE v_sp INT;
BEGIN
    SELECT sp INTO v_sp FROM pg6502.cpu;
    UPDATE pg6502.cpu SET x = v_sp, pc = pc + 1;
    PERFORM pg6502.set_nz(v_sp);
END;
$$ LANGUAGE plpgsql;
