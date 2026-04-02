LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- Data memory module

ENTITY data_mem IS
    PORT (
        clk      : IN  STD_LOGIC;
        addr     : IN  UNSIGNED(7 DOWNTO 0);
        data_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        wen      : IN  STD_LOGIC;
        en       : IN  STD_LOGIC;
        data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END data_mem;

ARCHITECTURE behavior OF data_mem IS
    TYPE RAM IS ARRAY (0 TO 255) OF STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL DATAMEM : RAM;
BEGIN

    PROCESS(clk)
    BEGIN
        IF (clk'EVENT AND clk = '0') THEN
            IF (en = '0') THEN
                data_out <= (OTHERS => '0');
            ELSE
                IF (wen = '0') THEN
                    data_out <= DATAMEM(to_integer(addr));
                ELSIF (wen = '1') THEN
                    DATAMEM(to_integer(addr)) <= data_in;
                    data_out <= (OTHERS => '0');
                END IF;
            END IF;
        END IF;
    END PROCESS;
     
END behavior;
