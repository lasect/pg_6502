-- Load Klaus Dormann 6502 Functional Test

\copy pg6502.mem FROM 'tests/6502_functional_test.txt'

UPDATE pg6502.cpu SET pc = 1024;

SELECT 'Test loaded. PC=' || pc || ', mem rows=' || (SELECT count(*) FROM pg6502.mem) FROM pg6502.cpu;