CREATE OR REPLACE FUNCTION pg6502.execute_instruction()
RETURNS TEXT AS $$
DECLARE
    v_pc       INT;
    v_opcode   INT;
    v_mnemonic TEXT;
    v_mode     TEXT;
BEGIN
    -- Fetch: read opcode at current PC
    SELECT pc INTO v_pc FROM pg6502.cpu;
    v_opcode := pg6502.mem_read(v_pc);

    -- Decode: look up the opcode
    SELECT mnemonic, mode
    INTO v_mnemonic, v_mode
    FROM pg6502.opcode_table
    WHERE opcode = v_opcode;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Unknown opcode: $% at PC $%',
            to_hex(v_opcode), to_hex(v_pc);
    END IF;

    -- Execute: dispatch to the right opcode function
    CASE v_mnemonic
        WHEN 'LDA' THEN PERFORM pg6502.op_lda(v_mode, v_pc);
        WHEN 'LDX' THEN PERFORM pg6502.op_ldxy(v_mode, 0, v_pc);
        WHEN 'LDY' THEN PERFORM pg6502.op_ldxy(v_mode, 1, v_pc);
        WHEN 'STA' THEN PERFORM pg6502.op_sta(v_mode, v_pc);
        WHEN 'STX' THEN PERFORM pg6502.op_stxy(v_mode, 0, v_pc);
        WHEN 'STY' THEN PERFORM pg6502.op_stxy(v_mode, 1, v_pc);
        WHEN 'TAX' THEN PERFORM pg6502.op_tax();
        WHEN 'TAY' THEN PERFORM pg6502.op_tay();
        WHEN 'TXA' THEN PERFORM pg6502.op_txa();
        WHEN 'TYA' THEN PERFORM pg6502.op_tya();
        WHEN 'ADC' THEN PERFORM pg6502.op_adc(v_mode, v_pc);
        WHEN 'SBC' THEN PERFORM pg6502.op_sbc(v_mode, v_pc);
        WHEN 'INC' THEN PERFORM pg6502.op_inc(v_mode, v_pc);
        WHEN 'DEC' THEN PERFORM pg6502.op_dec(v_mode, v_pc);
        WHEN 'INX' THEN PERFORM pg6502.op_inx();
        WHEN 'DEX' THEN PERFORM pg6502.op_dex();
        WHEN 'INY' THEN PERFORM pg6502.op_iny();
        WHEN 'DEY' THEN PERFORM pg6502.op_dey();
        WHEN 'AND' THEN PERFORM pg6502.op_and(v_mode, v_pc);
        WHEN 'ORA' THEN PERFORM pg6502.op_ora(v_mode, v_pc);
        WHEN 'EOR' THEN PERFORM pg6502.op_eor(v_mode, v_pc);
        WHEN 'CMP' THEN PERFORM pg6502.op_cmp(v_mode, v_pc);
        WHEN 'CPX' THEN PERFORM pg6502.op_cpx(v_mode, v_pc);
        WHEN 'CPY' THEN PERFORM pg6502.op_cpy(v_mode, v_pc);
        WHEN 'NOP' THEN PERFORM pg6502.op_nop();
        WHEN 'JMP' THEN PERFORM pg6502.op_jmp(v_mode, v_pc);
        WHEN 'JSR' THEN PERFORM pg6502.op_jsr(v_pc);
        WHEN 'RTS' THEN PERFORM pg6502.op_rts();
        WHEN 'RTI' THEN PERFORM pg6502.op_rti();
        WHEN 'BCC' THEN PERFORM pg6502.op_bcc(v_pc);
        WHEN 'BCS' THEN PERFORM pg6502.op_bcs(v_pc);
        WHEN 'BEQ' THEN PERFORM pg6502.op_beq(v_pc);
        WHEN 'BNE' THEN PERFORM pg6502.op_bne(v_pc);
        WHEN 'BVC' THEN PERFORM pg6502.op_bvc(v_pc);
        WHEN 'BVS' THEN PERFORM pg6502.op_bvs(v_pc);
        WHEN 'BPL' THEN PERFORM pg6502.op_bpl(v_pc);
        WHEN 'BMI' THEN PERFORM pg6502.op_bmi(v_pc);
        WHEN 'PHA' THEN PERFORM pg6502.op_pha();
        WHEN 'PLA' THEN PERFORM pg6502.op_pla();
        WHEN 'PHP' THEN PERFORM pg6502.op_php();
        WHEN 'PLP' THEN PERFORM pg6502.op_plp();
        WHEN 'TXS' THEN PERFORM pg6502.op_txs();
        WHEN 'TSX' THEN PERFORM pg6502.op_tsx();
        WHEN 'SEC' THEN PERFORM pg6502.op_sec();
        WHEN 'CLC' THEN PERFORM pg6502.op_clc();
        WHEN 'SEI' THEN PERFORM pg6502.op_sei();
        WHEN 'CLI' THEN PERFORM pg6502.op_cli();
        WHEN 'CLV' THEN PERFORM pg6502.op_clv();
        WHEN 'SED' THEN PERFORM pg6502.op_sed();
        WHEN 'CLD' THEN PERFORM pg6502.op_cld();
        WHEN 'BIT' THEN PERFORM pg6502.op_bit(v_mode, v_pc);
        WHEN 'ASL' THEN PERFORM pg6502.op_asl(v_mode, v_pc);
        WHEN 'LSR' THEN PERFORM pg6502.op_lsr(v_mode, v_pc);
        WHEN 'ROL' THEN PERFORM pg6502.op_rol(v_mode, v_pc);
        WHEN 'ROR' THEN PERFORM pg6502.op_ror(v_mode, v_pc);
        WHEN 'BRK' THEN PERFORM pg6502.op_brk();
        ELSE RAISE EXCEPTION 'Unimplemented mnemonic: %', v_mnemonic;
    END CASE;

    RETURN v_mnemonic;
END;
$$ LANGUAGE plpgsql;
