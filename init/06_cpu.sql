CREATE OR REPLACE FUNCTION pg6502.reset()
RETURNS VOID AS $$
DECLARE
    v_start_addr INT;
BEGIN
    v_start_addr := pg6502.mem_read16(65532);

    UPDATE pg6502.cpu SET
        a      = 0,
        x      = 0,
        y      = 0,
        sp     = 255,
        pc     = v_start_addr,
        flag_n = FALSE,
        flag_v = FALSE,
        flag_b = FALSE,
        flag_d = FALSE,
        flag_i = TRUE,
        flag_z = FALSE,
        flag_c = FALSE;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION pg6502.run(p_max_cycles INT DEFAULT 100000, p_log_interval INT DEFAULT 1000000)
RETURNS INT AS $$
DECLARE
    v_result TEXT;
    v_cycles INT := 0;
    v_pc INT;
BEGIN
    LOOP
        v_result := pg6502.execute_instruction();
        v_cycles := v_cycles + 1;

        IF v_cycles % p_log_interval = 0 THEN
            SELECT pc INTO v_pc FROM pg6502.cpu;
            RAISE NOTICE 'Cycles: %, PC: %', v_cycles, v_pc;
        END IF;

        EXIT WHEN v_result = 'BRK';
        EXIT WHEN v_cycles >= p_max_cycles;
    END LOOP;

    RETURN v_cycles;
END;
$$ LANGUAGE plpgsql;
