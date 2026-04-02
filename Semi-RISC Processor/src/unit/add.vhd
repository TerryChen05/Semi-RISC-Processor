LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32-bit incrementer used for the PC

ENTITY add IS
    PORT (
        A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        B : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END add;

ARCHITECTURE description OF add IS
BEGIN

    B <= A + 1; -- A + 4

END description;
