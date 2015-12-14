library ieee;
use ieee.std_logic_1164.all;
use work.HardwareController.all;

package MIPSCPU is

	-- Define clock, reset and enable/disable control related constants and subtypes.
	subtype Clock_t is std_logic;
	subtype Reset_t is std_logic;
	subtype EnablingControl_t is std_logic;
	constant FUNC_ENABLED : std_logic := '0';
	constant FUNC_DISABLED : std_logic := '1';
	
	subtype ReadyStatus_t is std_logic;
	constant STATUS_BUSY : std_logic := '0';
	constant STATUS_READY : std_logic := '1';
	
	-- General numerical properties of the processor
	-- The data width of register
	constant MIPS_CPU_DATA_WIDTH : integer := 32;
	subtype CPUData_t is
		std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		
	constant MIPS_CPU_DOUBLE_WORD_DATA_WIDTH : integer := 2 * MIPS_CPU_DATA_WIDTH;
	subtype CPUDoubleWordData_t is
		std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		
	-- Memory access and mapping related (sub)types and constants
	constant MIPS_RAM_ADDRESS_WIDTH : integer := 32;
	constant MIPS_RAM_DATA_WIDTH : integer := 32;
	subtype RAMData_t is std_logic_vector(MIPS_RAM_DATA_WIDTH - 1 downto 0);
	subtype RAMAddress_t is std_logic_vector(MIPS_RAM_ADDRESS_WIDTH - 1 downto 0);
	type RAMControl_t is
		record
			writeEnabled : EnablingControl_t;
			readEnabled : EnablingControl_t;
			address : RAMAddress_t;
			data : RAMData_t;
		end record;

	constant ISA_ADDRESS_SPACE : CPUData_t := x"b4000000";
	constant ISA_ADDRESS_SPACE_MASK : CPUData_t := x"FFFFF000";
	constant KERNEL_ADDRESS_SPACE : CPUData_t := x"80000000";
	constant KERNEL_ADDRESS_SPACE_MASK : CPUData_t := x"FFC00000";
	constant USER_ADDRESS_SPACE : CPUData_t := x"00000000";
	constant USER_ADDRESS_SPACE_MASK : CPUData_t := x"FFC00000";

	-- The address width of the registers in primary processor
	constant MIPS_CPU_REGISTER_ADDRESS_WIDTH: integer := 5;
	subtype RegisterAddress_t is
		std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);

	-- The number of registers in primarty processor
	constant MIPS_CPU_REGISTER_COUNT: integer := 2**MIPS_CPU_REGISTER_ADDRESS_WIDTH;
	type RegisterFileControl_t is
		record
			address : RegisterAddress_t;
			data : CPUData_t;
		end record;

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
	subtype InstructionFunct_t is
		std_logic_vector(MIPS_CPU_INSTRUCTION_FUNCT_WIDTH - 1 downto 0);

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
	constant MIPS_CPU_INSTRUCTION_OPCODE_SH : InstructionOpcode_t := "101001";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SB : InstructionOpcode_t := "101000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_BNE : InstructionOpcode_t := "000101";
	constant MIPS_CPU_INSTRUCTION_OPCODE_BEQ : InstructionOpcode_t := "000100";
	constant MIPS_CPU_INSTRUCTION_OPCODE_J : InstructionOpcode_t := "000010";
	constant MIPS_CPU_INSTRUCTION_OPCODE_JAL : InstructionOpcode_t := "000011";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL : InstructionOpcode_t := "000000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SLTI : InstructionOpcode_t := "001010";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SLTIU : InstructionOpcode_t := "001011";
	constant MIPS_CPU_INSTRUCTION_OPCODE_REGIMM : InstructionOpcode_t := "000001";
	constant MIPS_CPU_INSTRUCTION_OPCODE_BGTZ : InstructionOpcode_t := "000111";
	constant MIPS_CPU_INSTRUCTION_OPCODE_BLEZ : InstructionOpcode_t := "000110";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LB : InstructionOpcode_t := "100000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LBU : InstructionOpcode_t := "100100";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LH : InstructionOpcode_t := "100001";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LHU : InstructionOpcode_t := "100101";
	constant MIPS_CPU_INSTRUCTION_OPCODE_LUI : InstructionOpcode_t := "001111";
	constant MIPS_CPU_INSTRUCTION_OPCODE_CP0 : InstructionOpcode_t := "010000";
	constant MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL2 : InstructionOpcode_t := "011100";

	-- MIPS CPU rt for the regimm opcode
	constant MIPS_CPU_INSTRUCTION_RT_BGEZ :
		std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0) := "00001";
	constant MIPS_CPU_INSTRUCTION_RT_BLTZ :
		std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0) := "00000";

	-- MIPS CPU funct for the special opcode
	constant MIPS_CPU_INSTRUCTION_FUNCT_ADDU : InstructionFunct_t := "100001";
	constant MIPS_CPU_INSTRUCTION_FUNCT_AND : InstructionFunct_t := "100100";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SUBU : InstructionFunct_t := "100011";
	constant MIPS_CPU_INSTRUCTION_FUNCT_OR : InstructionFunct_t := "100101";
	constant MIPS_CPU_INSTRUCTION_FUNCT_XOR : InstructionFunct_t := "100110";
	constant MIPS_CPU_INSTRUCTION_FUNCT_NOR : InstructionFunct_t := "100111";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SLT : InstructionFunct_t := "101010";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SLTU : InstructionFunct_t := "101011";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SLLV : InstructionFunct_t := "000100";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SRLV : InstructionFunct_t := "000110";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SRAV : InstructionFunct_t := "000111";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SLL : InstructionFunct_t := "000000";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SRL : InstructionFunct_t := "000010";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SRA : InstructionFunct_t := "000011";
	constant MIPS_CPU_INSTRUCTION_FUNCT_JR : InstructionFunct_t := "001000";
	constant MIPS_CPU_INSTRUCTION_FUNCT_JALR : InstructionFunct_t := "001001";
	constant MIPS_CPU_INSTRUCTION_FUNCT_SYSCALL : InstructionFunct_t := "001100";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MFHI : InstructionFunct_t := "010000";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MFLO : InstructionFunct_t := "010010";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MTHI : InstructionFunct_t := "010001";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MTLO : InstructionFunct_t := "010011";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MULT : InstructionFunct_t := "011000";
	constant MIPS_CPU_INSTRUCTION_FUNCT_MULTU : InstructionFunct_t := "011001";
	
	-- MIPS CPU funct for the special2 opcode
	constant MIPS_CPU_INSTRUCTION_FUNCT_MUL : InstructionFunct_t := "000010";

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
	constant ALU_OPERATION_EQUAL :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00101";
	constant ALU_OPERATION_NOT_EQUAL :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00110";
	constant ALU_OPERATION_LOGIC_NOR :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "00111";
	constant ALU_OPERATION_LESS_THAN_SIGNED :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "01000";
	constant ALU_OPERATION_LESS_THAN_UNSIGNED :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "01001";
	constant ALU_OPERATION_SHIFT_LEFT :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "01010";
	constant ALU_OPERATION_SHIFT_RIGHT_LOGIC :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "01011";
	constant ALU_OPERATION_SHIFT_RIGHT_ARITH :
		std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0) := "01100";
		
	-- Register and hardware register related (sub)types and constants.
	constant REGISTER_OPERATION_READ : std_logic := '0';
	constant REGISTER_OPERATION_WRITE : std_logic := '1';

	type RegisterControl_t is
		record
			operation : std_logic;
			data : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
		end record;
	
	type HardwareRegisterControl_t is
		record
			operation : std_logic;
			address : CPUData_t;
			data : CPUData_t;
		end record;

	--! Parameters related to physics RAM bus.
	--constant PHYSICS_RAM_ADDRESS_WIDTH : integer := 20;
	--constant PHYSICS_RAM_DATA_WIDTH : integer := 32;

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
			immIsPCValue : std_logic;
			pcControl : RegisterControl_t;
		end record;

	type PipelinePhaseIDEXInterface_t is
		record
			operand1 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operand2 : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			operation : std_logic_vector(ALU_OPERATION_CTRL_WIDTH - 1 downto 0);
			targetReg : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			resultIsRAMAddr : std_logic;

			-- When this is enabled, the result will be an 0/1 value, that will
			-- determine whether extraImm will be write back to PC register.
			immIsPCValue : std_logic;

			-- When this is enabled, the result is considered as an immediate
			-- That will be write back to the mem addr evaluated by the ALU
			targetIsRAM : std_logic;
			extraImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			instructionOpcode : InstructionOpcode_t;
		end record;

	type PipelinePhaseEXMAInterface_t is
		record
			sourceIsRAM : std_logic;
			sourceRAMAddr : RAMAddress_t;
			sourceImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			targetIsRAM : std_logic;
			targetIsReg : std_logic;
			targetRAMAddr : RAMAddress_t;
			targetRegAddr : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			instructionOpcode : InstructionOpcode_t;
		end record;

	type PipelinePhaseMAWBInterface_t is
		record
			sourceImm : std_logic_vector(MIPS_CPU_DATA_WIDTH - 1 downto 0);
			targetIsRAM : std_logic;
			targetIsReg : std_logic;
			targetRAMAddr : RAMAddress_t;
			targetRegAddr : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
			instructionOpcode : InstructionOpcode_t;
		end record;
	
	type CPUDebugData_t is
	record
		pcValue : CPUData_t;
		primaryRegisterFile : mips_register_file_port;
		currentInstruction : Instruction_t;
	end record;

end package;


package body MIPSCPU is
end package body;
