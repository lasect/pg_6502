-- each addressing mode is implemented as a function that returns
-- an effective address in the ram to read from/write to

-- IMM - immediate: operand is the byte right after opcode
-- eg: LDA #$05 -> load value after 5 into A
CREATE OR REPLACE FUNCTION pg6502.addr_immediate(p_pc INT)
RETURNS INT AS $$
BEGIN
    RETURN p_pc + 1;
END
$$ LANGUAGE plpgsql;

-- ZP - zero page: operand is in the first 256 bytes of RAM ($0000 - $00FF)
-- eg: LDA $42 -> load from address $0042
CREATE OR REPLACE FUNCTION pg6502.addr_zero_page(p_pc INT)
RETURNS INT AS $$
BEGIN
    RETURN pg6502.mem_read(p_pc + 1);
END
$$ LANGUAGE plpgsql;

-- ZP,X - zero page, x: just like ZP but with an X reg added.
-- can be used for iterating arrays
-- eg: LDA $40,X -> load from $0040 + X & $FF
CREATE OR REPLACE FUNCTION pg6502.addr_zero_page_x(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_x INT;
BEGIN
    SELECT x INTO v_x from pg6502.cpu;
    RETURN (pg6502.mem_read(p_pc + 1) + v_x) & 255;
END
$$ LANGUAGE plpgsql;

-- ZP,Y - zero page, y: just like ZP but with an Y reg added.
CREATE OR REPLACE FUNCTION pg6502.addr_zero_page_y(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_y INT;
BEGIN
    SELECT y INTO v_y from pg6502.cpu;
    RETURN (pg6502.mem_read(p_pc + 1) + v_y) & 255;
END
$$ LANGUAGE plpgsql;

-- ABS: absolute: first 2 bytes after opcode form 16 bit addr (LE)
-- eg: LDA $4400 -> load from $4400
CREATE OR REPLACE FUNCTION pg6502.addr_absolute(p_pc INT)
RETURNS INT AS $$
BEGIN
    RETURN pg6502.mem_read16(p_pc + 1);
END
$$ LANGUAGE plpgsql;

-- ABS,X: absolute x: 16 bit addr with X added.
CREATE OR REPLACE FUNCTION pg6502.addr_absolute_x(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_x  INT;
BEGIN
    SELECT x INTO v_x from pg6502.cpu;
    RETURN (pg6502.mem_read16(p_pc + 1) + v_x);
END
$$ LANGUAGE plpgsql;

-- ABS,Y: absolute y: 16 bit addr with Y added.
CREATE OR REPLACE FUNCTION pg6502.addr_absolute_y(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_y  INT;
BEGIN
    SELECT y INTO v_y from pg6502.cpu;
    RETURN (pg6502.mem_read16(p_pc + 1) + v_y);
END
$$ LANGUAGE plpgsql;

-- (IND) - Indirect: operand points to a 16-bit pointer
-- e.g. JMP ($1234) -> read word at $1234, jump to that address
CREATE OR REPLACE FUNCTION pg6502.addr_indirect(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_ptr INT;
BEGIN
    v_ptr := pg6502.mem_read16(p_pc + 1);
    RETURN pg6502.mem_read16(v_ptr);
END
$$ LANGUAGE plpgsql;

-- (IND,X) - Indexed Indirect: (ZP + X) then deref
-- e.g. LDA ($20,X) with X=5 -> read ptr from $0025
CREATE OR REPLACE FUNCTION pg6502.addr_indirect_x(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_x  INT;
    v_ptr INT;
BEGIN
    SELECT x INTO v_x from pg6502.cpu;
    v_ptr := (pg6502.mem_read(p_pc + 1) + v_x) & 255;
    RETURN pg6502.mem_read16(v_ptr);
END
$$ LANGUAGE plpgsql;

-- (IND),Y - Indirect Indexed: deref then add Y
-- e.g. LDA ($20),Y -> read ptr from $0020, add Y
CREATE OR REPLACE FUNCTION pg6502.addr_indirect_y(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_y  INT;
    v_ptr INT;
BEGIN
    SELECT y INTO v_y from pg6502.cpu;
    v_ptr := pg6502.mem_read16(pg6502.mem_read(p_pc + 1));
    RETURN v_ptr + v_y;
END
$$ LANGUAGE plpgsql;

-- REL - Relative: signed offset for branches
-- returns target address as PC + offset (signed)
CREATE OR REPLACE FUNCTION pg6502.addr_relative(p_pc INT)
RETURNS INT AS $$
DECLARE
    v_offset INT;
BEGIN
    v_offset := pg6502.mem_read(p_pc + 1);
    IF v_offset >= 128 THEN
        v_offset := v_offset - 256;
    END IF;
    RETURN p_pc + 2 + v_offset;
END
$$ LANGUAGE plpgsql;

-- Stack operations (stack lives at $0100-$01FF, grows down from $FF)
CREATE OR REPLACE FUNCTION pg6502.stack_push(p_val INT)
RETURNS VOID AS $$
DECLARE
    v_sp INT;
BEGIN
    SELECT sp INTO v_sp FROM pg6502.cpu;
    PERFORM pg6502.mem_write(256 + v_sp, p_val);
    UPDATE pg6502.cpu SET sp = (v_sp - 1) & 255;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.stack_pop()
RETURNS INT AS $$
DECLARE
    v_sp INT;
    v_val INT;
BEGIN
    SELECT sp INTO v_sp FROM pg6502.cpu;
    v_sp := (v_sp + 1) & 255;
    v_val := pg6502.mem_read(256 + v_sp);
    UPDATE pg6502.cpu SET sp = v_sp;
    RETURN v_val;
END
$$ LANGUAGE plpgsql;