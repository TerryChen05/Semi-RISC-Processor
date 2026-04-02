LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32-bit General Purpose Register with asynchronous clear and synchronous load.

ENTITY register32 IS
    PORT (
        d   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);    -- input
        ld  : IN  STD_LOGIC;                        -- load/enable.
        clr : IN  STD_LOGIC;                        -- async. clear.
        clk : IN  STD_LOGIC;                        -- clock.
        Q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)     -- output.
    );
END register32;

ARCHITECTURE description OF register32 IS
BEGIN

    PROCESS(ld, clk, clr) 
    BEGIN
        IF clr = '1' THEN
            Q <= (OTHERS => '0');
        ELSIF rising_edge(clk) AND ld = '1' THEN
            Q <= d;
        END IF;
    END PROCESS;

END description;

