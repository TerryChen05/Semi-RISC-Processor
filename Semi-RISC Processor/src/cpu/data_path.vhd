LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

-- interconnection of CPU components including ALU, Registers, and Data Memory.

ENTITY data_path IS
    PORT(
        Clk, mClk                  : IN  STD_LOGIC;
        WEN, EN                    : IN  STD_LOGIC;
        Clr_A, Ld_A                : IN  STD_LOGIC;
        Clr_B, Ld_B                : IN  STD_LOGIC;
        Clr_C, Ld_C                : IN  STD_LOGIC;
        Clr_Z, Ld_Z                : IN  STD_LOGIC;
        ClrPC, Ld_PC               : IN  STD_LOGIC;
        ClrIR, Ld_IR               : IN  STD_LOGIC;
        Out_A                      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Out_B                      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Out_C                      : OUT STD_LOGIC;
        Out_Z                      : OUT STD_LOGIC;
        Out_PC                     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Out_IR                     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        Inc_PC                     : IN  STD_LOGIC;
        ADDR_OUT                   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        DATA_IN                    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        DATA_BUS, MEM_OUT, MEM_IN  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        MEM_ADDR                   : OUT UNSIGNED(7 DOWNTO 0);
        DATA_MUX                   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        REG_MUX                    : IN  STD_LOGIC;
        A_MUX, B_MUX               : IN  STD_LOGIC;
        IM_MUX1                    : IN  STD_LOGIC;
        IM_MUX2                    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        ALU_Op                     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0)
    );
END ENTITY;

ARCHITECTURE behavior OF data_path IS

    COMPONENT data_mem IS
        PORT(
            clk      : IN  STD_LOGIC;
            addr     : IN  UNSIGNED(7 DOWNTO 0);
            data_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wen      : IN  STD_LOGIC;
            en       : IN  STD_LOGIC;
            data_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT register32 IS
        PORT(
            d   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ld  : IN  STD_LOGIC;
            clr : IN  STD_LOGIC;
            clk : IN  STD_LOGIC;
            Q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT pc IS
        PORT(
            clr : IN  STD_LOGIC;
            clk : IN  STD_LOGIC;
            ld  : IN  STD_LOGIC;
            inc : IN  STD_LOGIC;
            d   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            q   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT LZE IS
        PORT( 
            LZE_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            LZE_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT UZE IS
        PORT( 
            UZE_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            UZE_out : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT RED IS
        PORT( 
            RED_in  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            RED_out : OUT UNSIGNED(7 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux2to1 IS
        PORT( 
            s      : IN  STD_LOGIC;
            w0, w1 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            f      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT mux4to1 IS
        PORT( 
            s              : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            X1, X2, X3, X4 : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            f              : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT alu IS
        PORT( 
            a      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            b      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            op     : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            zero   : OUT STD_LOGIC;
            cout   : OUT STD_LOGIC
        );
    END COMPONENT;

    SIGNAL IR_OUT            : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data_bus_s        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL LZE_out_PC        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL LZE_out_A_Mux     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL LZE_out_B_Mux     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL RED_out_Data_Mem  : UNSIGNED(7 DOWNTO 0);
    SIGNAL A_Mux_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL B_Mux_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_A_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_B_out         : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL reg_Mux_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL data_mem_out      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL UZE_IM_MUX1_out   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IM_MUX1_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL LZE_IM_MUX2_out   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL IM_MUX2_out       : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ALU_out           : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL zero_flag         : STD_LOGIC;
    SIGNAL carry_flag        : STD_LOGIC;
    SIGNAL temp              : STD_LOGIC_VECTOR(31 DOWNTO 0) := (OTHERS => '0');
    SIGNAL out_pc_sig        : STD_LOGIC_VECTOR(31 DOWNTO 0);

BEGIN

    IR: register32 
        PORT MAP (
            d   => data_bus_s, 
            ld  => Ld_IR, 
            clr => ClrIR, 
            clk => Clk, 
            Q   => IR_OUT
        );

    LZE_PC: LZE 
        PORT MAP (
            LZE_in  => IR_OUT, 
            LZE_out => LZE_out_PC
        );

    PC0: PC 
        PORT MAP (
            clr => ClrPC, 
            clk => Clk, 
            ld  => Ld_PC, 
            inc => Inc_PC, 
            d   => LZE_out_PC, 
            q   => out_pc_sig
        );

    LZE_A_Mux: LZE 
        PORT MAP (
            LZE_in  => IR_OUT, 
            LZE_out => LZE_out_A_Mux
        );

    A_Mux0: mux2to1 
        PORT MAP (
            s  => A_MUX, 
            w0 => data_bus_s, 
            w1 => LZE_out_A_Mux, 
            f  => A_Mux_out
        );

    Reg_A: register32 
        PORT MAP (
            d   => A_Mux_out, 
            ld  => Ld_A, 
            clr => Clr_A, 
            clk => Clk, 
            Q   => reg_A_out
        );

    LZE_B_Mux: LZE 
        PORT MAP (
            LZE_in  => IR_OUT, 
            LZE_out => LZE_out_B_Mux
        );

    B_Mux0: mux2to1 
        PORT MAP (
            s  => B_MUX, 
            w0 => data_bus_s, 
            w1 => LZE_out_B_Mux, 
            f  => B_Mux_out
        );

    Reg_B: register32 
        PORT MAP (
            d   => B_Mux_out, 
            ld  => Ld_B, 
            clr => Clr_B, 
            clk => Clk, 
            Q   => reg_B_out
        );

    Reg_Mux0: mux2to1 
        PORT MAP (
            s  => REG_MUX, 
            w0 => reg_A_out, 
            w1 => reg_B_out, 
            f  => reg_Mux_out
        );

    RED_Data_Mem: RED 
        PORT MAP (
            RED_in  => IR_OUT, 
            RED_out => RED_out_data_mem
        );

    Data_Mem0: data_mem 
        PORT MAP (
            clk      => mClk, 
            addr     => RED_out_data_mem, 
            data_in  => reg_Mux_out, 
            wen      => WEN, 
            en       => EN, 
            data_out => data_mem_out
        );

    UZE_IM_MUX1: UZE 
        PORT MAP (
            UZE_in  => IR_OUT, 
            UZE_out => UZE_IM_MUX1_out
        );

    IM_MUX1a: mux2to1 
        PORT MAP (
            s  => IM_MUX1, 
            w0 => reg_A_out, 
            w1 => UZE_IM_MUX1_out, 
            f  => IM_MUX1_out
        );

    LZE_IM_MUX2: LZE 
        PORT MAP (
            LZE_in  => IR_OUT, 
            LZE_out => LZE_IM_MUX2_out
        );

    IM_MUX2a: mux4to1 
        PORT MAP (
            s  => IM_MUX2, 
            X1 => reg_B_out, 
            X2 => LZE_IM_MUX2_out, 
            X3 => (temp(31 DOWNTO 1) & '1'), 
            X4 => (OTHERS => '0'), 
            f  => IM_MUX2_out
        );

    ALU0: alu 
        PORT MAP (
            a      => IM_MUX1_out, 
            b      => IM_MUX2_out, 
            op     => ALU_Op, 
            result => ALU_out, 
            zero   => zero_flag, 
            cout   => carry_flag
        );

    DATA_MUX0: mux4to1 
        PORT MAP (
            s  => DATA_MUX, 
            X1 => DATA_IN, 
            X2 => data_mem_out, 
            X3 => ALU_out, 
            X4 => (OTHERS => '0'), 
            f  => data_bus_s
        );

    DATA_BUS <= data_bus_s;
    OUT_A    <= reg_A_out;
    OUT_B    <= reg_B_out;
    OUT_IR   <= IR_OUT;
    ADDR_OUT <= out_pc_sig;
    OUT_PC   <= out_pc_sig;
    MEM_ADDR <= RED_out_Data_Mem;
    MEM_IN   <= reg_Mux_out;
    MEM_OUT  <= data_mem_out;

END behavior;
