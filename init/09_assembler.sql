-- Simple 6502 Assembler
-- Converts assembly text to binary

CREATE OR REPLACE FUNCTION pg6502.assemble(p_source TEXT)
RETURNS BYTEA AS $$
DECLARE
    v_result BYTEA := '';
    v_line TEXT;
    v_lines TEXT[];
    v_parts TEXT[];
    v_mnemonic TEXT;
    v_operand TEXT;
    v_mode TEXT;
    v_first_byte INT;
    v_addr INT;
    v_byte INT;
    v_temp TEXT;
    v_pos INT;
    v_hex TEXT;
BEGIN
    v_lines := string_to_array(p_source, E'\n');
    
    FOR i IN 1..array_length(v_lines, 1) LOOP
        v_line := TRIM(v_lines[i]);
        
        -- Skip empty lines and comments
        IF v_line = '' OR SUBSTRING(v_line FROM 1 FOR 1) = ';' THEN
            CONTINUE;
        END IF;
        
        -- Remove inline comments
        v_line := SPLIT_PART(v_line, ';', 1);
        v_line := TRIM(v_line);
        
        -- Skip lines that are just labels
        IF SUBSTRING(v_line FROM LENGTH(v_line) FOR 1) = ':' THEN
            CONTINUE;
        END IF;
        
        -- Check for inline label (label: opcode operand)
        v_pos := POSITION(':' IN v_line);
        IF v_pos > 0 THEN
            v_line := TRIM(SUBSTRING(v_line FROM v_pos + 1));
        END IF;
        
        -- Split by whitespace
        v_parts := regexp_split_to_array(v_line, '\s+');
        
        IF array_length(v_parts, 1) < 1 THEN
            CONTINUE;
        END IF;
        
        v_mnemonic := UPPER(v_parts[1]);
        
        -- Handle implied opcodes (no operand)
        IF array_length(v_parts, 1) = 1 THEN
            SELECT opcode INTO v_first_byte
            FROM pg6502.opcode_table
            WHERE mnemonic = v_mnemonic AND mode = 'implied'
            LIMIT 1;
            
            IF NOT FOUND THEN
                RAISE EXCEPTION 'Unknown implied opcode: %', v_mnemonic;
            END IF;
            
            v_hex := to_hex(v_first_byte);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
            CONTINUE;
        END IF;
        
        v_operand := TRIM(v_parts[2]);
        
        -- Check for branch opcodes (relative addressing)
        IF v_mnemonic IN ('BNE', 'BEQ', 'BPL', 'BMI', 'BVC', 'BVS', 'BCC', 'BCS') THEN
            v_mode := 'relative';
            -- Handle hex offset like $F2
            IF SUBSTRING(v_operand FROM 1 FOR 1) = '$' THEN
                v_temp := SUBSTRING(v_operand FROM 2);
                v_byte := ('x' || v_temp)::bit(8)::int;
            ELSE
                v_byte := v_operand::int;
            END IF;
        -- Immediate: #$val
        ELSIF SUBSTRING(v_operand FROM 1 FOR 2) = '#$' THEN
            v_mode := 'immediate';
            v_temp := SUBSTRING(v_operand FROM 3);
            v_byte := ('x' || v_temp)::bit(8)::int;
        -- Indexed X: $addr,X
        ELSIF v_operand ~ '^\$[0-9A-Fa-f]+,[Xx]$' THEN
            v_pos := POSITION(',' IN v_operand);
            v_temp := SUBSTRING(v_operand, 2, v_pos - 2);
            v_addr := ('x' || LPAD(v_temp, 4, '0'))::bit(16)::int;
            IF LENGTH(v_temp) <= 2 THEN
                v_mode := 'zero_page_x';
                v_byte := v_addr & 255;
            ELSE
                v_mode := 'absolute_x';
                v_byte := v_addr;
            END IF;
        -- Indexed Y: $addr,Y
        ELSIF v_operand ~ '^\$[0-9A-Fa-f]+,[Yy]$' THEN
            v_pos := POSITION(',' IN v_operand);
            v_temp := SUBSTRING(v_operand, 2, v_pos - 2);
            v_addr := ('x' || LPAD(v_temp, 4, '0'))::bit(16)::int;
            IF LENGTH(v_temp) <= 2 THEN
                v_mode := 'zero_page_y';
                v_byte := v_addr & 255;
            ELSE
                v_mode := 'absolute_y';
                v_byte := v_addr;
            END IF;
        -- Non-indexed memory operand: $addr
        ELSIF v_operand ~ '^\$[0-9A-Fa-f]+$' THEN
            v_temp := SUBSTRING(v_operand FROM 2);
            IF LENGTH(v_temp) <= 2 THEN
                v_mode := 'zero_page';
                v_addr := ('x' || LPAD(v_temp, 2, '0'))::bit(8)::int;
                v_byte := v_addr;
            ELSE
                v_mode := 'absolute';
                v_addr := ('x' || LPAD(v_temp, 4, '0'))::bit(16)::int;
                v_byte := v_addr;
            END IF;
        ELSE
            RAISE EXCEPTION 'Cannot parse operand: %', v_operand;
        END IF;
        
        SELECT opcode INTO v_first_byte
        FROM pg6502.opcode_table
        WHERE mnemonic = v_mnemonic AND mode = v_mode
        LIMIT 1;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION 'Unknown opcode: % %', v_mnemonic, v_mode;
        END IF;
        
        v_hex := to_hex(v_first_byte);
        IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
        v_result := v_result || decode(v_hex, 'hex');
        
        IF v_mode = 'relative' THEN
            v_hex := to_hex(v_byte);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
        ELSIF v_mode = 'immediate' THEN
            v_hex := to_hex(v_byte);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
        ELSIF v_mode IN ('zero_page', 'zero_page_x', 'zero_page_y') THEN
            v_hex := to_hex(v_byte);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
        ELSIF v_mode IN ('absolute', 'absolute_x', 'absolute_y') THEN
            v_hex := to_hex(v_byte & 255);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
            v_hex := to_hex((v_byte >> 8) & 255);
            IF LENGTH(v_hex) = 1 THEN v_hex := '0' || v_hex; END IF;
            v_result := v_result || decode(v_hex, 'hex');
        END IF;
    END LOOP;
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;
