LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Reduction Unit: Extracts the lower 8 bits of a 32-bit vector for memory addressing.

ENTITY RED IS
    PORT (
        red_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        red_out : OUT UNSIGNED(7 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF RED IS
BEGIN

    red_out <= UNSIGNED(red_in(7 DOWNTO 0));
     
END behavior;
