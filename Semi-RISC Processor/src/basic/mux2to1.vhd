LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32-bit 2-to-1 Multiplexer used for signal routing within the Datapath.

ENTITY mux2to1 IS
    PORT (
        s      : IN  STD_LOGIC;
        w0, w1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        f      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END mux2to1;

ARCHITECTURE description OF mux2to1 IS
BEGIN

    WITH s SELECT
        f <= w0 WHEN '0', 
             w1 WHEN OTHERS;

END description;
