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

    -- BRK: halt
    IF v_mnemonic = 'BRK' THEN
        RETURN 'BRK';
    END IF;

    -- Execute: dispatch to the right opcode function
    CASE v_mnemonic
        WHEN 'LDA' THEN PERFORM pg6502.op_lda(v_mode);
        WHEN 'LDX' THEN PERFORM pg6502.op_ldxy(v_mode, 0);
        WHEN 'LDY' THEN PERFORM pg6502.op_ldxy(v_mode, 1);
        WHEN 'STA' THEN PERFORM pg6502.op_sta(v_mode);
        WHEN 'STX' THEN PERFORM pg6502.op_stxy(v_mode, 0);
        WHEN 'STY' THEN PERFORM pg6502.op_stxy(v_mode, 1);
        WHEN 'TAX' THEN PERFORM pg6502.op_tax();
        WHEN 'TAY' THEN PERFORM pg6502.op_tay();
        WHEN 'TXA' THEN PERFORM pg6502.op_txa();
        WHEN 'TYA' THEN PERFORM pg6502.op_tya();
        WHEN 'ADC' THEN PERFORM pg6502.op_adc(v_mode);
        WHEN 'SBC' THEN PERFORM pg6502.op_sbc(v_mode);
        WHEN 'INC' THEN PERFORM pg6502.op_inc(v_mode);
        WHEN 'DEC' THEN PERFORM pg6502.op_dec(v_mode);
        WHEN 'INX' THEN PERFORM pg6502.op_inx();
        WHEN 'DEX' THEN PERFORM pg6502.op_dex();
        WHEN 'INY' THEN PERFORM pg6502.op_iny();
        WHEN 'DEY' THEN PERFORM pg6502.op_dey();
        WHEN 'AND' THEN PERFORM pg6502.op_and(v_mode);
        WHEN 'ORA' THEN PERFORM pg6502.op_ora(v_mode);
        WHEN 'EOR' THEN PERFORM pg6502.op_eor(v_mode);
        WHEN 'CMP' THEN PERFORM pg6502.op_cmp(v_mode);
        WHEN 'CPX' THEN PERFORM pg6502.op_cpx(v_mode);
        WHEN 'CPY' THEN PERFORM pg6502.op_cpy(v_mode);
        WHEN 'NOP' THEN PERFORM pg6502.op_nop();
        WHEN 'JMP' THEN PERFORM pg6502.op_jmp(v_mode);
        WHEN 'JSR' THEN PERFORM pg6502.op_jsr();
        WHEN 'RTS' THEN PERFORM pg6502.op_rts();
        WHEN 'RTI' THEN PERFORM pg6502.op_rti();
        WHEN 'BCC' THEN PERFORM pg6502.op_bcc();
        WHEN 'BCS' THEN PERFORM pg6502.op_bcs();
        WHEN 'BEQ' THEN PERFORM pg6502.op_beq();
        WHEN 'BNE' THEN PERFORM pg6502.op_bne();
        WHEN 'BVC' THEN PERFORM pg6502.op_bvc();
        WHEN 'BVS' THEN PERFORM pg6502.op_bvs();
        WHEN 'BPL' THEN PERFORM pg6502.op_bpl();
        WHEN 'BMI' THEN PERFORM pg6502.op_bmi();
        WHEN 'PHA' THEN PERFORM pg6502.op_pha();
        WHEN 'PLA' THEN PERFORM pg6502.op_pla();
        WHEN 'PHP' THEN PERFORM pg6502.op_php();
        WHEN 'PLP' THEN PERFORM pg6502.op_plp();
        WHEN 'TXS' THEN PERFORM pg6502.op_txs();
        WHEN 'TSX' THEN PERFORM pg6502.op_tsx();
        WHEN 'BIT' THEN PERFORM pg6502.op_bit(v_mode);
        WHEN 'ASL' THEN PERFORM pg6502.op_asl(v_mode);
        WHEN 'LSR' THEN PERFORM pg6502.op_lsr(v_mode);
        WHEN 'ROL' THEN PERFORM pg6502.op_rol(v_mode);
        WHEN 'ROR' THEN PERFORM pg6502.op_ror(v_mode);
        ELSE RAISE EXCEPTION 'Unimplemented mnemonic: %', v_mnemonic;
    END CASE;

    RETURN v_mnemonic;
END;
$$ LANGUAGE plpgsql;
