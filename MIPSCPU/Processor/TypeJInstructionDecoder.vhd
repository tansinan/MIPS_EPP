library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeJInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		pcValue : in std_logic_vector (MIPS_CPU_DATA_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeJInstructionDecoder is
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
begin
	opcode <= instruction
		(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);

	result.pcControl.operation <= REGISTER_OPERATION_WRITE;
	result.pcControl.data(1 downto 0) <= (others => '0');
	-- TODO: This implementation seems not compliant with MIPS standard!
	-- The upper bits should be the instruction in the branch delay slot.
	result.pcControl.data
		(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_OPCODE_LO + 2) <=
	pcValue(MIPS_CPU_DATA_WIDTH - 1 downto MIPS_CPU_INSTRUCTION_OPCODE_LO + 2);

	result.pcControl.data(MIPS_CPU_INSTRUCTION_OPCODE_LO + 1 downto 2) <=
	instruction(MIPS_CPU_INSTRUCTION_OPCODE_LO - 1 downto 0);

	result.regDest <= (others => '0');
	result.resultIsRAMAddr <= FUNC_DISABLED;
end architecture;
