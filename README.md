# 32-Bit Semi-RISC Processor Architecture

A synthesizable, 32-bit CPU architecture designed using VHDL.

Designed and verified in **Quartus Prime 16.0** for the **Altera Cyclone IV E (EP4CE115F29C7)** FPGA.

---

## Table of Contents
- [Project Overview](#project-overview)

- [Key Features](#key-features)

- [System Organization](#system-organization)

- [Architectural Features](#architectural-features)
  - [The 32-Bit Datapath](#the-32-bit-datapath)
  - [Instruction Execution & FSM](#instruction-execution--fsm)
  - [Arithmetic Logic Unit (ALU)](#arithmetic-logic-unit-alu)
  - [Memory & Storage Subsystem](#memory--storage-subsystem)

- [Technical Implementation](#technical-implementation)

- [Build & Simulation](#build--simulation)

- [Instruction Set Alternate Example](#instruction-set-alternate-example)

- [Appendix: Additional Charts](#appendix-additional-charts)

---

## Project Overview

This project implements a design of a **32-bit Semi-RISC Central Processing Unit**. The architecture handles 32-bit standard logic vectors, implementing a structural hierarchy from basic components to a fully integrated top-level system.

The core objective was to engineer a system capable of multi-cycle instruction execution, emphasizing synchronous data movement and control signal timing.

---
Instruction Set Example: 
* instructions can be initialized in the `.mif`
* see [Appendix](#appendix-additional-charts) for full ISA Table and Control Unit Signals

| Address | Hex Value | Mnemonic | Operation |
| :---: | :---: | :--- | :--- |
| `00` | `0000AAAA` | **LDAI** | Load Immediate value `0xAAAA` into Register A |
| `01` | `1000AAAA` | **LDBI** | Load Immediate value `0xAAAA` into Register B |
| `02` | `600000F0` | **BEQ** | If (A == B) Branch to `0x00F0` |

#### Example Timing Simulation Output
<div align="center">
  <img width="1461" height="528" alt="Example Timing Waveform 1" src="https://github.com/user-attachments/assets/e739fe4d-ea68-4c64-a09f-f21f96b9b8cf" />
  <br>
  <b>`sim/cpu_test_sim.vwf` (LDAI, LDBI, BEQ)</b>
</div>


---

## Key Features

### Core Specifications
* **Architecture**: 32-bit Harvard based architecture with separate instruction and data storage.
* **Multi-Cycle Control Logic**: A Moore Finite State Machine (FSM) managing Instruction Fetch, Decode, and Execution cycles.
* **Falling-Edge Memory Sync**: Data memory operations are synchronized to the falling edge to ensure datapath stability on the rising edge.
* **Asynchronous Global Reset**: A specialized reset circuit with a 4-cycle debounce logic to ensure clean system initialization.

### Hardware Units
* **Ripple-Carry Hierarchy**: Modular adder design scaling from 1-bit full adders to a 32-bit adder unit.
* **Zero Extension Modules**: Integrated **LZE** and **UZE** units for immediate value manipulation.
* **Reduced Memory Interface**: High-bit to low-bit reduction logic for memory addressing.

---

## System Organization

```text
Semi-RISC_Processor/
├── src/                        
│   ├── basic/                  # Basic Level
│   │   ├── fulladd.vhd         # 1-bit Full Adder
│   │   ├── LZE.vhd             # Lower Zero Extender
│   │   ├── UZE.vhd             # Upper Zero Extender
│   │   ├── RED.vhd             # Bit Reducer
│   │   ├── mux2to1.vhd         # 2-to-1 Multiplexer
│   │   └── mux4to1.vhd         # 4-to-1 Multiplexer
│   ├── units/                  # Intermediate Level
│   │   ├── add.vhd             # 32-bit Incrementer
│   │   ├── adder4.vhd          # 4-bit Ripple-Carry Adder
│   │   ├── adder16.vhd         # 16-bit Ripple-Carry Adder
│   │   ├── adder32.vhd         # 32-bit Ripple-Carry Adder
│   │   ├── register32.vhd      # 32-bit General Purpose Register
│   │   ├── alu.vhd             # Arithmetic Logic Unit
│   │   ├── pc.vhd              # Program Counter
│   │   ├── data_mem.vhd        # Synchronous RAM
│   │   └── reset_circuit.vhd   # Debounced initialization
│   └── cpu/                    # Top Level
│       ├── cpu.vhd             # Structural Top-level
│       ├── control_new.vhd     # Instruction decoder
│       └── datapath.vhd        # Component interconnect
├── data/                       # Pre-load Assets
|   ├── system_memory.vhd       # Wizard-generated RAM
|   ├── system_memory.qip       # Quartus IP Project File
│   └── system_memory.mif       # Memory Initialization File
├── sim/                        # Verification
|   ├── reset_circuit.vwf       # Reset Circuitry Simulation Waveform
|   ├── cpu_test_sim.vwf        # Test Sim Simulation Waveform
│   └── cpu_test_sim.vhd        # Simulation wrapper
└── quartus/                    # Project files (.qpf, .qsf)
```
## Architectural Features

### The 32-Bit Datapath
The datapath serves to facilitate the processors synchronized data transfer between the registers, the Arithmetic Logic Unit (ALU), and system memory. 

<div align="center">
  <img width="650" height="490" alt="CPU Datapath" src="https://github.com/user-attachments/assets/eec012bf-6727-4437-81d0-b9deaa957471" />
  <br>
  <b>CPU Data-Path</b>
</div>
<br>


* **Instruction Pipeline**: Features a 32-bit Instruction Register (IR) that holds the current opcode and operands fetched from memory.
* **Instruction Format**: All instructions are 32-bits long and require a 4-byte memory word. For direct addressing mode, the 16-lower instruction bits represent an address location or a constant number. The two instruction formats are shown below.
* **Operand Routing**: Usage of 32-bit wide 2-to-1 and 4-to-1 multiplexers (`mux2to1`, `mux4to1`) to handle bus conflicts, selecting between immediate values, register data, and memory outputs.
* **Register Set**: General-purpose registers (A, B) implemented with synchronous load and asynchronous clear capabilities to ensure predictable state transitions. Registers C and Z are 1-bit status registers used to indicate Carry and Zero detect.

<div align="center">
  <img width="384" height="205" alt="instruction format" src="https://github.com/user-attachments/assets/b9fe9605-c8a2-4363-a31c-871250667881" />
  <br>
  <b>Instruction Format</b>
</div>

<br>

<div align="center">
  <img width="386" height="194" alt="user registers" src="https://github.com/user-attachments/assets/1193b1bb-b08a-48dd-9b89-120e7c1cb384" />
  <br>
  <b>User Registers</b>
</div>


### Instruction Execution & FSM
The `control_new` module acts to orchestrate the systems multi-cycle execution of instructions through a Moore-type FSM.

1.  **T0: Stage 0 (Fetch)**: Generates the control signals to load the next instruction from `system_memory` into the IR based on the Program Counter (PC) address.
2.  **T1: Stage 1 (Pre-Decode & Increment)**: The PC is incremented. Pre-decoding and signal assertions for Load and Store instructions (to account for the setup times needed by the data memory).
3.  **T2: Stage 2 (Decode & Execute)**: Instruction decoded from IR, triggers specific control lines (e.g., `ld_A`, `wen`, `ALU_op`) to complete the instruction, such as writing back to a register or performing a memory store.

<div align="center">
  <img width="380" height="520" alt="Instruction Execution State Chart" src="https://github.com/user-attachments/assets/d8cb5520-568a-4105-8fd6-024cf7fbfa4d" />
  <br>
  <b>Instruction Execution State Chart</b>
</div>

<br>
  
### Arithmetic Logic Unit (ALU)
The ALU is designed to have 6 operations, capable of performing it's 32-bit operations in a single clock cycle once operands are stabilized.

<div align="center">
<details open>
<summary>ALU Op-Codes and Operations</summary>

| Function | Opcode | Operand Performed | Description | 
| :--- | :---: | :--- | :--- |
| **AND** | `000` | Result <= a AND b | Bitwise logical AND of two 32-bit operands |
| **OR** | `001` | Result <= a OR b | Bitwise logical OR of two 32-bit operands |
| **ADD** | `010` | Result <= a + b | 32-bit addition via ripple-carry approach |
| **SUB** | `110` | Result <= a - b | 32-bit subtraction using 2's complement logic |
| **ROL** | `100` | Result <= a << 1 | Logical Shift Left 1-bit position) |
| **ROR** | `101` | Result <= a >> 1 | Logical Shift Right 1-bit position) |

</details>
</div>

### Memory & Storage Subsystem
The memory unit uses a Harvard based architecture, meaning that two separate memories are needed (one for reading and writing data, and the other for instruction handling).
The memory unit has an 8-bit address input (addr) and 32-bit data input and output (data_in and data_out) to allow it to store and retrieve data.


<div align="center">
<details open>
<summary>Data Memory Unit Functions</summary>

| en | wen | Function | data_out |
| :---: | :---: | :---: | :---: |
| 0 | X | N/A | 0 |
| 1 | 0 | Read | M[addr] |
| 1 | 1 | Write M[addr] <= data in | 0 |

</details>
</div>

* **System Memory**: MegaCore RAM block implementation: a 64-word x 32-bit high-speed RAM block initialized via the `.mif` file.
* **Address Reduction**: The `red` (Reduction) unit scales the internal 32-bit address bus down to the 6-bit physical address space required by the memory IP.
* **Clock Phase Shifting**: To prevent data hazards, the memory clock (`mem_clk`) is run at twice the frequency of the `cpu_clk`, such that memory data is valid and stable before the CPU's rising edge (single-cycle access latency).


<div align="center">
  <img width="355" height="189" alt="Data Memory Unit" src="https://github.com/user-attachments/assets/f3d5bde8-04ec-4fba-a44d-727f00bc4547" />
  <br>
  <b>256 word x 32-bit Data Memory Unit</b>
</div>

---

## Technical Implementation

### Other Details
* **Modular Hierarchical VHDL**: The design follows a strict structural approach. For instance, `adder32.vhd` is composed of two `adder16.vhd` blocks, which are composed of `adder4.vhd` blocks, which are in turn composed of `fulladd.vhd` base units.
* **Resource Optimization**: By using `LZE` (Lower Zero Extension) and `UZE` (Upper Zero Extension), the processor can handle 16-bit immediate values within a 32-bit instruction word without requiring additional complex logic.

### Toolchain
* **Synthesis**: Altera Quartus Prime 16.0.
* **Target Device**: Cyclone IV E EP4CE115F29C7 (Development Board: DE2-115).
* **Verification**: Simulation was performed using the Quartus University Program VWF (Vector Waveform File) to validate timing propagation and logic accuracy.

---

## Build & Simulation

### Synthesis
1.  Launch **Quartus Prime 16.0**.
2.  Open the project file: `quartus/Semi-RISC_Processor.qpf`.
3.  Set `cpu_test_sim.vhd` as the **Top-Level Entity**.
4.  Run **Start Compilation**.

### Simulation
1.  Open the simulation file: `sim/cpu_test_sim.vwf`.
2.  Ensure the simulation engine is set to **ModelSim-Altera**.
3.  Click **Run Functional Simulation** or **Run Timing Simulation**.
4.  Observe the signals to verify the instruction sequence matches the boot instructions and exhibits proper behaviour.

---

## Instruction Set Alternate Example

The processor is pre-loaded with a demonstration program in `data/system_memory.mif`:

| Address | Hex Value | Mnemonic | Operation |
| :---: | :---: | :--- | :--- |
| `00` | `0000AAAA` | **LDAI** | Load Immediate value `0xAAAA` into Register A |
| `01` | `20000001` | **STA** | Store Register A into Memory Address `0x01` |
| `02` | `75000000` | **CLR_A** | Clear Register A to `0x00000000` |
| `03` | `90000001` | **LDA** | Load value from Memory Address `0x01` back into Register A |

#### Example Timing Simulation Output
<div align="center">
  <img width="1079" height="330" alt="Example Timing Waveform 2" src="https://github.com/user-attachments/assets/99d499a8-a727-4465-9e6d-942091e5dd25" />
  <br>
  <b>`sim/cpu_test_sim.vwf` (LDAI, STA, CLRA, LDA)</b>
</div>

## Appendix: Additional Charts
<details>
<summary>Instruction Set Architecture (ISA) - Part 1: Data Transfer & Branching</summary>

| Mnemonic | Function | IR[31..28] | IR[27..16] | IR[15..0] |
| :---: | :---: | :---: | :---: | :---: |
| **LDAI** | A <= IR[15:0] | 0000 | X | IMM |
| **LDBI** | B <= IR[15:0] | 0001 | X | IMM |
| **STA** | M[ADDRS] <= A, ADDRS <= IR[15:0] | 0010 | X | ADDRS |
| **STB** | M[ADDRS] <= B, ADDRS <= IR[15:0] | 0011 | X | ADDRS |
| **LDA** | A <= M[ADDRS], ADDRS <= IR[15:0] | 1001 | X | ADDRS |
| **LDB** | B <= M[ADDRS], ADDRS <= IR[15:0] | 1010 | X | ADDRS |
| **LUI** | A[31:16] <= IR[15:0], A[15:0] <= 0 | 0100 | X | IMM |
| **JMP** | PC <= IR[15:0] | 0101 | X | ADDRS |
| **BEQ** | IF(A==B) then PC <= IR[15:0] | 0110 | X | ADDRS |
| **BNE** | IF(A!=B) then PC <= IR[15:0] | 1000 | X | ADDRS |

</details>

<details>
<summary>Instruction Set Architecture (ISA) - Part 2: Arithmetic & Logic</summary>

| Mnemonic | Function | IR[31..28] | IR[27..24] | IR[15..0] |
| :---: | :---: | :---: | :---: | :---: |
| **ADD** | A <= A + B | 0111 | 0000 | X |
| **ADDI** | A <= A + IR[15:0] | 0111 | 0001 | IMM |
| **SUB** | A <= A - B | 0111 | 0010 | X |
| **INCA** | A <= A + 1 | 0111 | 0011 | X |
| **ROL** | A <= A << 1 | 0111 | 0100 | X |
| **CLRA** | A <= 0 | 0111 | 0101 | X |
| **CLRB** | B <= 0 | 0111 | 0110 | X |
| **CLRC** | C <= 0 | 0111 | 0111 | X |
| **CLRZ** | Z <= 0 | 0111 | 1000 | X |
| **ANDI** | A <= A AND IR[15:0] | 0111 | 1001 | IMM |
| **TSTZ** | If Z = 1 then PC <= PC + 1 | 0111 | 1010 | X |
| **AND** | A <= A AND B | 0111 | 1011 | X |
| **TSTC** | If C = 1 then PC <= PC + 1 | 0111 | 1100 | X |
| **ORI** | A <= A OR IR[15:0] | 0111 | 1101 | IMM |
| **DECA** | A <= A - 1 | 0111 | 1110 | X |
| **ROR** | A <= A >> 1 | 0111 | 1111 | X |

</details>

<details>
<summary>Data-Path Control Signals Table</summary>

| INST | CLR_IR LD_IR | LD_PC INC_PC | CLR_A LD_A | CLR_B LD_B | CLR_C LD_C | CLR_Z LD_Z | ALU OP | EN WEN | A/B MUX | REG MUX | Data MUX | IM_MUX1 IM_MUX2 |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **LDA** | 0/0 | 0/0 | 0/1 | 0/0 | 0/0 | 0/0 | XXX | 1/0 | 0/X | X | 01 | X |
| **LDB** | 0/0 | 0/0 | 0/0 | 0/1 | 0/0 | 0/0 | XXX | 1/0 | X/0 | X | 01 | X |
| **STA** | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | 1/1 | X | 0 | X | X |
| **STB** | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | 1/1 | X | 1 | X | X |
| **JMP** | 0/0 | 1/0 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | X | X | X | X | X |
| **LDAI** | 0/0 | 0/0 | 0/1 | 0/0 | 0/0 | 0/0 | XXX | X | 1/X | X | X | X |
| **LDBI** | 0/0 | 0/0 | 0/0 | 0/1 | 0/0 | 0/0 | XXX | X | X/1 | X | X | X |
| **LUI** | 0/0 | 0/0 | 0/1 | 1/0 | 0/0 | 0/0 | 001 | X | 0/X | X | 10 | 1/X |
| **ANDI** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 000 | X | 0/X | X | 10 | 0/01 |
| **DECA** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 110 | X | 0/X | X | 10 | 0/10 |
| **ADD** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 010 | X | 0/X | X | 10 | 0/00 |
| **SUB** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 110 | X | 0/X | X | 10 | 0/00 |
| **INCA** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 010 | X | 0/X | X | 10 | 0/10 |
| **AND** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 000 | X | 0/X | X | 10 | 0/00 |
| **ADDI** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 010 | X | 0/X | X | 10 | 0/01 |
| **ORI** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 001 | X | 0/X | X | 10 | 0/01 |
| **ROL** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 100 | X | 0/X | X | 10 | 0/X |
| **ROR** | 0/0 | 0/0 | 0/1 | 0/0 | 0/1 | 0/1 | 101 | X | 0/X | X | 10 | 0/X |
| **CLRA** | 0/0 | 0/0 | 1/0 | 0/0 | 0/0 | 0/0 | XXX | X | X | X | X | X |
| **CLRB** | 0/0 | 0/0 | 0/0 | 1/0 | 0/0 | 0/0 | XXX | X | X | X | X | X |
| **CLRC** | 0/0 | 0/0 | 0/0 | 0/0 | 1/0 | 0/0 | XXX | X | X | X | X | X |
| **CLRZ** | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | 1/0 | XXX | X | X | X | X | X |
| **PC <= PC+4** | 0/0 | 1/1 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | X | X | X | X | X |
| **IR <= M[INST]** | 0/1 | 0/0 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | X | X | X | 00 | X |
| **PC <= IR[15..0]** | 0/0 | 1/0 | 0/0 | 0/0 | 0/0 | 0/0 | XXX | X | X | X | X | X |

</details>

