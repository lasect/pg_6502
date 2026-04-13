-- Load and run Fibonacci program

-- Load the Fibonacci program using assembler
-- BNE LOOP -> BNE with relative offset -14 (0xF2)
SELECT pg6502.load_program(pg6502.assemble(
'LDA #$00' || chr(10) ||
'STA $20' || chr(10) ||
'LDA #$01' || chr(10) ||
'STA $21' || chr(10) ||
'LDX #$09' || chr(10) ||
'LDA $20' || chr(10) ||
'ADC $21' || chr(10) ||
'STA $20' || chr(10) ||
'LDA $21' || chr(10) ||
'STA $21' || chr(10) ||
'DEX' || chr(10) ||
'BNE $F2' || chr(10) ||
'STA $22' || chr(10) ||
'BRK'
), 1024);

-- Reset CPU
SELECT pg6502.reset();

-- Run for a reasonable number of cycles
SELECT pg6502.run(500, 100) AS cycles;

-- Show final state
SELECT 
    'PC=' || pc || ' A=' || a || ' X=' || x || ' Y=' || y AS cpu_state,
    'Result at $20=' || (SELECT val FROM pg6502.mem WHERE addr = 32) ||
    ', at $21=' || (SELECT val FROM pg6502.mem WHERE addr = 33) ||
    ', at $22=' || (SELECT val FROM pg6502.mem WHERE addr = 34) AS memory
FROM pg6502.cpu;