library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeRInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
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
	with funct select arithResult.operation <=
		ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_FUNCT_ADDU,
		(others => 'X') when others;
	
	with opcode select result <=
		arithResult when MIPS_CPU_INSTRUCTION_OPCODE_SPECIAL;

end architecture;