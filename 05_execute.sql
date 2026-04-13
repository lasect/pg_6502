CREATE OR REPLACE FUNCTION pg_6502.execute_instruction()
RETURNS TEXT AS $$
DECLARE
    v_pc       INT;
    v_opcode   INT;
    v_mnemonic TEXT;
    v_mode     TEXT;
BEGIN
    -- Fetch: read opcode at current PC
    SELECT pc INTO v_pc FROM pg_6502.cpu;
    v_opcode := pg_6502.mem_read(v_pc);

    -- Decode: look up the opcode
    SELECT mnemonic, mode
    INTO v_mnemonic, v_mode
    FROM pg_6502.opcode_table
    WHERE opcode = v_opcode;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown opcode: $% at PC $%',
            to_hex(v_opcode), to_hex(v_pc);
    END IF;

    -- BRK: halt
    IF v_mnemonic = 'BRK' THEN
        RETURN 'BRK';
    END IF;

    -- Execute: dispatch to the right opcode function
    CASE v_mnemonic
        WHEN 'LDA' THEN PERFORM pg_6502.op_lda(v_mode);
        WHEN 'LDX' THEN PERFORM pg_6502.op_ldx(v_mode);
        WHEN 'LDY' THEN PERFORM pg_6502.op_ldy(v_mode);
        WHEN 'STA' THEN PERFORM pg_6502.op_sta(v_mode);
        WHEN 'STX' THEN PERFORM pg_6502.op_stx(v_mode);
        WHEN 'STY' THEN PERFORM pg_6502.op_sty(v_mode);
        WHEN 'TAX' THEN PERFORM pg_6502.op_tax();
        WHEN 'TAY' THEN PERFORM pg_6502.op_tay();
        WHEN 'TXA' THEN PERFORM pg_6502.op_txa();
        WHEN 'TYA' THEN PERFORM pg_6502.op_tya();
        WHEN 'ADC' THEN PERFORM pg_6502.op_adc(v_mode);
        WHEN 'SBC' THEN PERFORM pg_6502.op_sbc(v_mode);
        WHEN 'INC' THEN PERFORM pg_6502.op_inc(v_mode);
        WHEN 'DEC' THEN PERFORM pg_6502.op_dec(v_mode);
        WHEN 'INX' THEN PERFORM pg_6502.op_inx();
        WHEN 'DEX' THEN PERFORM pg_6502.op_dex();
        WHEN 'INY' THEN PERFORM pg_6502.op_iny();
        WHEN 'DEY' THEN PERFORM pg_6502.op_dey();
        WHEN 'AND' THEN PERFORM pg_6502.op_and(v_mode);
        WHEN 'ORA' THEN PERFORM pg_6502.op_ora(v_mode);
        WHEN 'EOR' THEN PERFORM pg_6502.op_eor(v_mode);
        WHEN 'CMP' THEN PERFORM pg_6502.op_cmp(v_mode);
        WHEN 'NOP' THEN PERFORM pg_6502.op_nop();
        ELSE RAISE EXCEPTION 'Unimplemented mnemonic: %', v_mnemonic;
    END CASE;

    RETURN v_mnemonic;
END;
$$ LANGUAGE plpgsql;
