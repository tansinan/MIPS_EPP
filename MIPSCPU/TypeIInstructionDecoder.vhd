library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeIInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeIInstructionDecoder is
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
	signal rs : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal rt : std_logic_vector(MIPS_CPU_REGISTER_ADDRESS_WIDTH - 1 downto 0);
	signal imm : std_logic_vector(MIPS_CPU_INSTRUCTION_IMM_WIDTH - 1 downto 0);
begin
	opcode <= instruction (MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
	rs <= instruction(MIPS_CPU_INSTRUCTION_RS_HI downto MIPS_CPU_INSTRUCTION_RS_LO);
	rt <= instruction(MIPS_CPU_INSTRUCTION_RT_HI downto MIPS_CPU_INSTRUCTION_RT_LO);
	imm <= instruction(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO);
	result.regAddr1 <= rs;
	result.regAddr2 <= rt;
	result.regDest <= rt;
	
	result.imm(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_IMM_HI + 1)
		<= (others => '0');

	result.imm(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO)
		<= instruction(MIPS_CPU_INSTRUCTION_IMM_HI downto MIPS_CPU_INSTRUCTION_IMM_LO);

	result.useImmOperand <= '1';
	
	with opcode select result.operation <=
		ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU,
		ALU_OPERATION_LOGIC_AND when MIPS_CPU_INSTRUCTION_OPCODE_ANDI,
		ALU_OPERATION_LOGIC_OR when MIPS_CPU_INSTRUCTION_OPCODE_ORI,
		ALU_OPERATION_LOGIC_XOR when MIPS_CPU_INSTRUCTION_OPCODE_XORI,
		ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_OPCODE_LW,
		ALU_OPERATION_ADD when MIPS_CPU_INSTRUCTION_OPCODE_SW,
		(others => 'X') when others;
		
	with opcode select result.resultIsRAMAddr <=
		FUNC_DISABLED when MIPS_CPU_INSTRUCTION_OPCODE_ADDIU,
		FUNC_DISABLED when MIPS_CPU_INSTRUCTION_OPCODE_ANDI,
		FUNC_DISABLED when MIPS_CPU_INSTRUCTION_OPCODE_ORI,
		FUNC_DISABLED when MIPS_CPU_INSTRUCTION_OPCODE_XORI,
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_LW,
		FUNC_ENABLED when MIPS_CPU_INSTRUCTION_OPCODE_SW,
		FUNC_DISABLED when others;

end architecture;

