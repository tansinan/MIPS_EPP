library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeRInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeRInstructionDecoder is
	signal rs : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rt : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rd : std_logic_vector (MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal opcode : std_logic_vector (MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal funct : std_logic_vector (MIPS_CPU_INSTRUCTION_FUNCT_WIDTH - 1 downto 0);
	signal shamt : std_logic_vector (MIPS_CPU_INSTRUCTION_SHAMT_WIDTH - 1 downto 0);
	signal arithResult : InstructionDecodingResult_t;
begin
	rs <= instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
	rt <= instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
	rd <= instruction(MIPS_CPU_INSTRUCTION_RD_HI downto MIPS_CPU_INSTRUCTION_RD_LO);
	opcode <= instruction(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
	funct <= instruction(MIPS_CPU_INSTRUCTION_FUNCT_HI downto MIPS_CPU_INSTRUCTION_FUNCT_LO);
	shamt <= instruction(MIPS_CPU_INSTRUCTION_SHAMT_HI downto MIPS_CPU_INSTRUCTION_SHAMT_LO);

	arithResult.regAddr1 <= rs;
	arithResult.regAddr2 <= rt;
	arithResult.regDest <= rd;
	arithResult.imm <= (others => 'X');
	arithResult.useImmOperand <= FUNC_ENABLED;
	arithResult.resultIsRAMAddr <= FUNC_DISABLED;
	arithResult.immIsPCValue <= FUNC_DISABLED;
	arithResult.pcControl <= (
		operation => REGISTER_OPERATION_READ,
		data => (others => '0')
	);
	with funct select arithResult.operation <=
		ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_FUNCT_ADDU,
		ALU_OPERATION_SUBTRACT when MIPS_CPU_INSTRUCTION_FUNCT_SUBU,
		ALU_OPERATION_LOGIC_OR when MIPS_CPU_INSTRUCTION_FUNCT_OR,
		ALU_OPERATION_LOGIC_XOR when MIPS_CPU_INSTRUCTION_FUNCT_XOR,
		ALU_OPERATION_LOGIC_NOR when MIPS_CPU_INSTRUCTION_FUNCT_NOR,
		ALU_OPERATION_LESS_THAN_SIGNED when MIPS_CPU_INSTRUCTION_FUNCT_SLT,
		ALU_OPERATION_LESS_THAN_UNSIGNED when MIPS_CPU_INSTRUCTION_FUNCT_SLTU,
		ALU_OPERATION_SHIFT_LEFT when MIPS_CPU_INSTRUCTION_FUNCT_SLLV,
		ALU_OPERATION_SHIFT_RIGHT_LOGIC when MIPS_CPU_INSTRUCTION_FUNCT_SRLV,
		ALU_OPERATION_SHIFT_RIGHT_ARITH when MIPS_CPU_INSTRUCTION_FUNCT_SRAV,
		(others => 'X') when others;

	arithResult.immIsPCValue <= FUNC_DISABLED;
	
	with opcode select result <=
		arithResult when MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL,
		arithResult when others;

end architecture;
