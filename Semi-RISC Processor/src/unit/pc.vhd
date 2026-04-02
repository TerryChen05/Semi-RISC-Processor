LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- 32-bit Program Counter unit. Loads a branch address or increments to next instruction.

ENTITY pc IS
    PORT (
        clr : IN    STD_LOGIC;
        clk : IN    STD_LOGIC;
        ld  : IN    STD_LOGIC;
        inc : IN    STD_LOGIC;
        d   : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
        q   : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0)
    );
END pc;

ARCHITECTURE description OF pc IS

    COMPONENT add
        PORT (
            A : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            B : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT mux2to1
        PORT (
            s      : IN  STD_LOGIC;
            w0, w1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            f      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    COMPONENT register32
        PORT (
            d   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ld  : IN  STD_LOGIC;
            clr : IN  STD_LOGIC;
            clk : IN  STD_LOGIC;
            Q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;
    
    SIGNAL add_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mux_out : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL q_out   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
BEGIN

    add0 : add PORT MAP (A => q_out, B => add_out);
    mux0 : mux2to1 PORT MAP (s => inc, w0 => d, w1 => add_out, f => mux_out);
    reg0 : register32 PORT MAP (d => mux_out, ld => ld, clr => clr, clk => clk, Q => q_out);
        
    q <= q_out;

END description;
