LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.NUMERIC_STD.ALL;

-- The 32-bit ALU

ENTITY alu IS
    PORT (
        a      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        b      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        op     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
        result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        zero   : OUT STD_LOGIC;
        cout   : OUT STD_LOGIC
    );
END alu;

ARCHITECTURE behavior OF alu IS

    COMPONENT adder32
        PORT (
            Cin   : IN  STD_LOGIC;
            X, Y  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            S     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            Cout  : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL result_s   : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_add : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL result_sub : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL cout_s     : STD_LOGIC := '0';
    SIGNAL cout_add   : STD_LOGIC := '0';
    SIGNAL cout_sub   : STD_LOGIC := '0';
    SIGNAL zero_s     : STD_LOGIC;

BEGIN

    add0 : adder32 PORT MAP (op(2), a, b, result_add, cout_add);
    sub0 : adder32 PORT MAP (op(2), a, NOT b, result_sub, cout_sub);

    PROCESS (a, b, op, result_add, result_sub, cout_add, cout_sub, result_s)
    BEGIN
        CASE (op) IS
            WHEN "000" =>              -- "000" a and b
                result_s <= a AND b;
                cout_s <= '0';
            WHEN "001" =>              -- "001" a or b
                result_s <= a OR b;
                cout_s <= '0';
            WHEN "010" =>              -- "010" a + b
                result_s <= result_add;
                cout_s <= cout_add;
            WHEN "011" =>              -- "011" b
                result_s <= b;
                cout_s <= '0';
            WHEN "110" =>              -- "110" a - b
                result_s <= result_sub;
                cout_s <= cout_sub;
            WHEN "100" =>              -- "100" a sll 1 (<<)
                result_s <= a(30 DOWNTO 0) & '0';
                cout_s <= a(31);
            WHEN "101" =>              -- "101" a srl 1 (>>)
                result_s <= '0' & a(31 DOWNTO 1);
                cout_s <= '0';
            WHEN OTHERS =>             -- "111" a
                result_s <= a; 
                cout_s <= '0';
        END CASE;

        CASE (result_s) IS
            WHEN (OTHERS => '0') =>
                zero_s <= '1';
            WHEN OTHERS =>
                zero_s <= '0';
        END CASE;
    END PROCESS;

    result <= result_s;
    cout <= cout_s;
    zero <= zero_s;
      
END behavior;
