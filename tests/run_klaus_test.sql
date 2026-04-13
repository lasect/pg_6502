-- Run Klaus Dormann 6502 Functional Test
-- Run with a high limit to let it complete
SELECT pg6502.run(150000000, 1000000) AS cycles;

-- Report final state
SELECT 
    'PC=' || pc || ' A=' || a || ' X=' || x || ' Y=' || y || 
    ' N=' || flag_n || ' Z=' || flag_z || ' C=' || flag_c || ' V=' || flag_v AS final_state,
    pc AS program_counter
FROM pg6502.cpu;