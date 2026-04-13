-- Load and run Fibonacci program

-- Load the Fibonacci program using assembler
-- Computes Fibonacci sequence with:
--   $20 = previous
--   $21 = current
--   $22 = temp/current result
-- Loop starts at CLC and branches back with relative offset -18 (0xEE).
SELECT pg6502.load_program(pg6502.assemble(
'LDA #$00' || chr(10) ||
'STA $20' || chr(10) ||
'LDA #$01' || chr(10) ||
'STA $21' || chr(10) ||
'LDX #$09' || chr(10) ||
'CLC' || chr(10) ||
'LDA $20' || chr(10) ||
'ADC $21' || chr(10) ||
'STA $22' || chr(10) ||
'LDA $21' || chr(10) ||
'STA $20' || chr(10) ||
'LDA $22' || chr(10) ||
'STA $21' || chr(10) ||
'DEX' || chr(10) ||
'BNE $EE' || chr(10) ||
'BRK'
), 1024);

-- Reset CPU
SELECT pg6502.reset();

-- Run for a reasonable number of cycles
SELECT pg6502.run(500, 100) AS cycles;

-- Assert expected values:
-- fib(9)=34 at $20, fib(10)=55 at $21 and $22
DO $$
DECLARE
    v20 INT;
    v21 INT;
    v22 INT;
BEGIN
    SELECT val INTO v20 FROM pg6502.mem WHERE addr = 32;
    SELECT val INTO v21 FROM pg6502.mem WHERE addr = 33;
    SELECT val INTO v22 FROM pg6502.mem WHERE addr = 34;

    IF v20 IS DISTINCT FROM 34 OR v21 IS DISTINCT FROM 55 OR v22 IS DISTINCT FROM 55 THEN
        RAISE EXCEPTION 'Fibonacci mismatch: $20=%, $21=%, $22=% (expected 34,55,55)',
            COALESCE(v20, -1), COALESCE(v21, -1), COALESCE(v22, -1);
    END IF;
END
$$;

-- Show final state
SELECT 
    'PC=' || pc || ' A=' || a || ' X=' || x || ' Y=' || y AS cpu_state,
    'Result at $20=' || COALESCE((SELECT val::TEXT FROM pg6502.mem WHERE addr = 32), 'NULL') ||
    ', at $21=' || COALESCE((SELECT val::TEXT FROM pg6502.mem WHERE addr = 33), 'NULL') ||
    ', at $22=' || COALESCE((SELECT val::TEXT FROM pg6502.mem WHERE addr = 34), 'NULL') AS memory
FROM pg6502.cpu;
