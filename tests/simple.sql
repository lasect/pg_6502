SELECT pg6502.load_program(pg6502.assemble(
'LDA #$00' || chr(10) ||
'STA $20' || chr(10) ||
'LDA #$55' || chr(10) ||
'STA $20' || chr(10) ||
'BRK'
), 1024);

SELECT pg6502.reset();
SELECT pg6502.run(100, 10);

SELECT * FROM pg6502.cpu;
SELECT * FROM pg6502.mem WHERE addr BETWEEN 30 AND 35;