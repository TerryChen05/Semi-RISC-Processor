LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Upper Zero Extension: Shifts the lower 16 bits of the input to the upper 16 bits.

ENTITY UZE IS
    PORT ( 
        uze_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        uze_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF UZE IS
    SIGNAL zeros : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN

    uze_out <= uze_in(15 DOWNTO 0) & zeros;
     
END behavior;
