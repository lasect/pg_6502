SELECT pg6502.reset();
SELECT pg6502.cpu.pc, pg6502.mem_read(pg6502.cpu.pc) FROM pg6502.cpu;
SELECT pg6502.execute_instruction();
SELECT pg6502.cpu.pc, pg6502.mem_read(pg6502.cpu.pc) FROM pg6502.cpu;
SELECT pg6502.execute_instruction();
SELECT pg6502.cpu.pc, pg6502.mem_read(pg6502.cpu.pc) FROM pg6502.cpu;
SELECT * FROM pg6502.mem WHERE addr = 32;