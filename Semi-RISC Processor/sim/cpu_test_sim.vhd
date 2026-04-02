LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

-- Top-level simulation connecting the CPU to the system memory.

ENTITY CPU_TEST_Sim IS
    PORT(
        cpuClk     : IN  STD_LOGIC;
        memClk     : IN  STD_LOGIC;
        rst        : IN  STD_LOGIC;
        -- Debug data
        outA, outB : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        outC, outZ : OUT STD_LOGIC;
        outIR      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        outPC      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Processor-Inst Memory Interface
        addrOut    : OUT STD_LOGIC_VECTOR(5 DOWNTO 0);
        wEn        : OUT STD_LOGIC;
        memDataOut : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        memDataIn  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        -- Processor State
        T_Info     : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        -- Data Memory Interface
        wen_mem    : OUT STD_LOGIC;
        en_mem     : OUT STD_LOGIC
    );
END CPU_TEST_Sim;

ARCHITECTURE behavior OF CPU_TEST_Sim IS

    COMPONENT system_memory
        PORT(
            address : IN  STD_LOGIC_VECTOR(5 DOWNTO 0);
            clock   : IN  STD_LOGIC;
            data    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wren    : IN  STD_LOGIC;
            q       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
        );
    END COMPONENT;

    COMPONENT cpu
        PORT(
            clk             : IN  STD_LOGIC;
            mem_clk         : IN  STD_LOGIC;
            rst             : IN  STD_LOGIC;
            dataIn          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0); 
            dataOut         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            addrOut         : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            wEn             : OUT STD_LOGIC;
            dOutA, dOutB    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            dOutC, dOutZ    : OUT STD_LOGIC;
            dOutIR          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            dOutPC          : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            outT            : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            wen_mem, en_mem : OUT STD_LOGIC
        );
    END COMPONENT;
    
    SIGNAL cpu_to_mem   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL mem_to_cpu   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL add_from_cpu : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wen_from_cpu : STD_LOGIC;

BEGIN

    main_memory : system_memory PORT MAP (
        address => add_from_cpu(5 DOWNTO 0),
        clock   => memClk,
        data    => cpu_to_mem,
        wren    => wen_from_cpu,
        q       => mem_to_cpu
    );

    main_processor : cpu PORT MAP (
        clk     => cpuClk,
        mem_clk => memClk,
        rst     => rst,
        dataIn  => mem_to_cpu,
        dataOut => cpu_to_mem,
        addrOut => add_from_cpu,
        wEn     => wen_from_cpu,
        dOutA   => outA,
        dOutB   => outB,
        dOutC   => outC,
        dOutZ   => outZ,
        dOutIR  => outIR,
        dOutPC  => outPC,
        outT    => T_Info,
        wen_mem => wen_mem,
        en_mem  => en_mem
    );
    
    addrOut    <= add_from_cpu(5 DOWNTO 0);
    wEn        <= wen_from_cpu;
    memDataOut <= mem_to_cpu;
    memDataIn  <= cpu_to_mem;

END behavior;
