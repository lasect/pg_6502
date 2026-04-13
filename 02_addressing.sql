-- each addressing mode is implemented as a function that returns
-- an effective address in the ram to read from/write to

-- IMM - immediate: operand is the byte right after opcode
-- eg: LDA #$05 -> load value after 5 into A
CREATE OR REPLACE FUNCTION pg6502.addr_imm()
RETURNS INT AS $$
DECLARE
    v_pc INT;
BEGIN
    SELECT pc INTO v_pc FROM pg6502.cpu;
    RETURN v_pc + 1;
END
$$ LANGUAGE plpgsql;

-- ZP - zero page: operand is in the first 256 bytes of RAM ($0000 - $00FF)
-- eg: LDA $42 -> load from address $0042
CREATE OR REPLACE FUNCTION pg6502.addr_zp()
RETURNS INT AS $$
DECLARE
    v_pc INT;
BEGIN
    SELECT pc INTO v_pc from pg6502.cpu;
    RETURN pg6502.mem_read(v_pc + 1);
END
$$ LANGUAGE plpgsql;

-- ZP,X - zero page, x: just like ZP but with an X reg added.
-- can be used for iterating arrays
-- eg: LDA $40,X -> load from $0040 + X & $FF
CREATE OR REPLACE FUNCTION pg6502.addr_zp_x()
RETURNS INT AS $$
DECLARE
    v_pc INT;
    v_x INT;
BEGIN
    SELECT pc, x INTO v_pc, v_x from pg6502.cpu;
    RETURN (pg6502.mem_read(v_pc + 1) + v_x) & 255;
END
$$ LANGUAGE plpgsql;

-- ABS: absolute: first 2 bytes after opcode form 16 bit addr (LE)
-- eg: LDA $4400 -> load from $4400
CREATE OR REPLACE FUNCTION pg6502.addr_abs()
RETURNS INT AS $$
DECLARE
    v_pc INT;
BEGIN
    SELECT pc INTO v_pc from pg6502.cpu;
    RETURN pg6502.mem_read16(v_pc + 1);
END
$$ LANGUAGE plpgsql;

-- ABS,X and ABS,Y: absolute x/y: 16 bit addr with X/Y added.
-- use for array access when array isn't in 0 page
-- eg: LDA $4400,X
--
-- v_T is toggle between X/Y. v_T = 0 -> X ELSE Y
CREATE OR REPLACE FUNCTION pg6502.addr_abs_xy(v_T INT)
RETURNS INT AS $$
DECLARE
   v_pc INT;
   v_M  INT;
BEGIN
    SELECT pc INTO v_pc from pg6502.cpu;
    if v_T = 0 THEN
        SELECT x INTO v_M from pg6502.cpu;
    ELSE
        SELECT y INTO v_M from pg6502.cpu;
    END IF;
    RETURN (pg6502.mem_read16(v_pc + 1) + v_M);
END
$$ LANGUAGE plpgsql;
