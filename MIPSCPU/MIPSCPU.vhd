library ieee;
use ieee.std_logic_1164.all;

package MIPSCPU is

	-- General numerical properties of the processor
	-- The data width of register
	constant MIPS_CPU_DATA_WIDTH : integer := 32;

	-- The address width of the registers in primary processor
	constant MIPS_CPU_REGISTER_ADDRESS_WIDTH: integer := 5;

	-- The number of registers in primarty processor
	constant MIPS_CPU_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;


	-- Data width constants related to the MIPS instructions
	-- The instruction width of the CPU
	constant MIPS_CPU_INSTRUCTION_WIDTH : integer := 32;

	-- Instruction opcode range
	constant MIPS_CPU_INSTRUCTION_OPCODE_HI : integer := 31;
	constant MIPS_CPU_INSTRUCTION_OPCODE_LO : integer := 26;
	constant MIPS_CPU_INSTRUCTION_OPCODE_WIDTH : integer :=
		MIPS_CPU_INSTRUCTION_OPCODE_HI - MIPS_CPU_INSTRUCTION_OPCODE_LO + 1;

	-- R/I Type Instruction RS range
	constant MIPS_CPU_INSTRUCTION_RS_HI : integer := 25;
	constant MIPS_CPU_INSTRUCTION_RS_LO : integer := 21;

	-- R/I Type Instruction RT range
	constant MIPS_CPU_INSTRUCTION_RT_HI : integer := 20;
	constant MIPS_CPU_INSTRUCTION_RT_LO : integer := 16;

	-- I Type Instruction IMM range
	constant MIPS_CPU_INSTRUCTION_IMM_HI : integer := 15;
	constant MIPS_CPU_INSTRUCTION_IMM_LO : integer := 0;
	constant MIPS_CPU_INSTRUCTION_IMM_WIDTH : integer :=
		MIPS_CPU_INSTRUCTION_IMM_HI - MIPS_CPU_INSTRUCTION_IMM_LO + 1;


	-- MIPS CPU instructions
	constant MIPS_CPU_INSTRUCTION_NOP :
		std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0) :=
		"00100100000000000000000000000000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ADDIU :
		std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0) := "001001";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ANDI :
		std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0) := "001100";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ORI :
		std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0) := "001101";
	constant MIPS_CPU_INSTRUCTION_OPCODE_XORI :
		std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0) := "001110";

	-- General
	constant ALU_OPERATION_CTRL_WIDTH : integer := 5;
	constant ALU_OPERATION_ADD :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00000";
	constant ALU_OPERATION_SUBTRACT :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00001";
	constant ALU_OPERATION_LOGIC_AND :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00010";
	constant ALU_OPERATION_LOGIC_OR :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00011";
	constant ALU_OPERATION_LOGIC_XOR :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00100";
	constant REGISTER_OPERATION_READ : std_logic := '0';
	constant REGISTER_OPERATION_WRITE : std_logic := '1';

	type mips_register_file_port is
		array(0 to MIPS_CPU_REGISTER_COUNT - 1) of std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);

end MIPSCPU;


package body MIPSCPU is
end MIPSCPU;
