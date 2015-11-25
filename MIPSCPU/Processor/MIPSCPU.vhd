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

	subtype Instruction_t is
		std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);

	-- Instruction opcode range
	constant MIPS_CPU_INSTRUCTION_OPCODE_HI : integer := 31;
	constant MIPS_CPU_INSTRUCTION_OPCODE_LO : integer := 26;
	constant MIPS_CPU_INSTRUCTION_OPCODE_WIDTH : integer :=
		MIPS_CPU_INSTRUCTION_OPCODE_HI - MIPS_CPU_INSTRUCTION_OPCODE_LO + 1;
	subtype InstructionOpcode_t is
		std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);

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

	-- R Type Instruction RD range
	constant MIPS_CPU_INSTRUCTION_RD_HI : integer := 15;
	constant MIPS_CPU_INSTRUCTION_RD_LO : integer := 11;

	-- R Type Instruction Shamt range
	constant MIPS_CPU_INSTRUCTION_SHAMT_HI : integer := 10;
	constant MIPS_CPU_INSTRUCTION_SHAMT_LO : integer := 6;
	constant MIPS_CPU_INSTRUCTION_SHAMT_WIDTH : integer :=
		MIPS_CPU_INSTRUCTION_SHAMT_HI - MIPS_CPU_INSTRUCTION_SHAMT_LO + 1;

	-- R Type Instruction Funct range
	constant MIPS_CPU_INSTRUCTION_FUNCT_HI : integer := 5;
	constant MIPS_CPU_INSTRUCTION_FUNCT_LO : integer := 0;
	constant MIPS_CPU_INSTRUCTION_FUNCT_WIDTH : integer :=
		MIPS_CPU_INSTRUCTION_FUNCT_HI - MIPS_CPU_INSTRUCTION_FUNCT_LO + 1;

	-- MIPS CPU instructions
	constant MIPS_CPU_INSTRUCTION_NOP :
		std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0) :=
		"00100100000000000000000000000000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ADDIU : InstructionOpcode_t := "001001";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ANDI : InstructionOpcode_t := "001100";
	constant MIPS_CPU_INSTRUCTION_OPCODE_ORI : InstructionOpcode_t := "001101";
	constant MIPS_CPU_INSTRUCTION_OPCODE_XORI : InstructionOpcode_t := "001110";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LW : InstructionOpcode_t := "100011";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SW : InstructionOpcode_t := "101011";
	constant MIPS_CPU_INSTRUCTION_OPCODE_J : InstructionOpcode_t := "000010";
	constant MIPS_CPU_INSTRUCTION_OPCODE_JAL : InstructionOpcode_t := "000011";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL : InstructionOpcode_t := "000000";

	-- MIPS CPU funct for the special opcode
	constant MIPS_CPU_INSTRUCTION_FUNCT_ADDU :
		std_logic_vector(MIPS_CPU_INSTRUCTION_FUNCT_WIDTH - 1 downto 0) := "100001";

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

	type RegisterControl_t is
		record
			operation : std_logic;
			data : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		end record;

	--! Parameters related to physics RAM bus.
	constant PHYSICS_RAM_ADDRESS_WIDTH : integer := 20;
	constant PHYSICS_RAM_DATA_WIDTH : integer := 32;

	type mips_register_file_port is
		array(0 to MIPS_CPU_REGISTER_COUNT - 1) of std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);


	--! InstructionDecodingResult_t: The internal representation of a instruction when decoded.
	--! regAddr1 : The register address of the first number may be used by ALU.
	--! resultIsRAMAddr :
	type InstructionDecodingResult_t is
		record
			regAddr1 : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			regAddr2 : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			regDest : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			imm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
			useImmOperand : std_logic;
			resultIsRAMAddr : std_logic;
			pcControl : RegisterControl_t;
		end record;

	type RAMWriteControl_t is
		record
			enable : std_logic;
			address : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			data: std_logic_vector(PHYSICS_RAM_DATA_WIDTH - 1 downto 0);
		end record;

	type RAMReadControl_t is
		record
			enable : std_logic;
			address : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
		end record;

	type PipelinePhaseIDEXInterface_t is
		record
			operand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
			targetReg : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			resultIsRAMAddr : std_logic;
			targetIsRAM : std_logic;
			extraImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		end record;

	type PipelinePhaseEXMAInterface_t is
		record
			sourceIsRAM : std_logic;
			sourceRAMAddr : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			sourceImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			targetIsRAM : std_logic;
			targetIsReg : std_logic;
			targetRAMAddr : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			targetRegAddr : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		end record;

	type PipelinePhaseMAWBInterface_t is
		record
			sourceImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			targetIsRAM : std_logic;
			targetIsReg : std_logic;
			targetRAMAddr : std_logic_vector(PHYSICS_RAM_ADDRESS_WIDTH - 1 downto 0);
			targetRegAddr : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
		end record;

	constant FUNC_ENABLED : std_logic := '0';
	constant FUNC_DISABLED : std_logic := '1';

end MIPSCPU;


package body MIPSCPU is
end MIPSCPU;
