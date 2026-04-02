LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Lower Zero Extension: Extends the lower 16 bits of the input to a 32-bit word by padding with zeros.

ENTITY LZE IS
    PORT( 
        lze_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        lze_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF LZE IS
    SIGNAL zeros : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
BEGIN

    lze_out <= zeros & lze_in(15 DOWNTO 0);
     
END behavior;
