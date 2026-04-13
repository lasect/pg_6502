DROP SCHEMA IF EXISTS pg6502 CASCADE;
CREATE SCHEMA pg6502;
set search_path = pg6502, public;

-- entire cpu is just one row
CREATE TABLE pg6502.cpu (
    a      INT  NOT NULL DEFAULT 0   CHECK (a  BETWEEN 0 AND 255),  -- accumulator
    x      INT  NOT NULL DEFAULT 0   CHECK (x  BETWEEN 0 AND 255),  -- index
    y      INT  NOT NULL DEFAULT 0   CHECK (y  BETWEEN 0 AND 255),  -- index
    sp     INT  NOT NULL DEFAULT 255 CHECK (sp BETWEEN 0 AND 255),  -- stack pointer
    pc     INT  NOT NULL DEFAULT 0   CHECK (pc BETWEEN 0 AND 65535), -- program counter

    -- Status flags (the P register, stored split)
    flag_n BOOL NOT NULL DEFAULT FALSE,  -- Negative
    flag_v BOOL NOT NULL DEFAULT FALSE,  -- Overflow
    flag_b BOOL NOT NULL DEFAULT FALSE,  -- Break
    flag_d BOOL NOT NULL DEFAULT FALSE,  -- Decimal (later ig)
    flag_i BOOL NOT NULL DEFAULT TRUE,   -- Interrupt disable
    flag_z BOOL NOT NULL DEFAULT FALSE,  -- Zero
    flag_c BOOL NOT NULL DEFAULT FALSE   -- Carry
);

-- seed it plz
INSERT INTO pg6502.cpu DEFAULT VALUES;

-- 64KB of flat memory. 1 row per byte.
CREATE TABLE pg6502.mem (
    addr INT PRIMARY KEY CHECK (addr BETWEEN 0 AND 65535),
    val  INT NOT NULL    CHECK (val  BETWEEN 0 AND 255)
);
