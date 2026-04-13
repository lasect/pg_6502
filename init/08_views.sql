CREATE OR REPLACE VIEW pg6502.state AS
SELECT
    a,
    x,
    y,
    sp,
    pc,
    to_hex(pc) AS pc_hex,
    CONCAT(
        CASE WHEN flag_n THEN 'N' ELSE '·' END,
        CASE WHEN flag_v THEN 'V' ELSE '·' END,
        '·',
        CASE WHEN flag_b THEN 'B' ELSE '·' END,
        CASE WHEN flag_d THEN 'D' ELSE '·' END,
        CASE WHEN flag_i THEN 'I' ELSE '·' END,
        CASE WHEN flag_z THEN 'Z' ELSE '·' END,
        CASE WHEN flag_c THEN 'C' ELSE '·' END
    ) AS flags
FROM pg6502.cpu;
