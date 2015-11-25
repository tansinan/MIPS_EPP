library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeJInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end entity;

architecture Behavioral of TypeJInstructionDecoder is
	signal opcode : std_logic_vector(MIPS_CPU_INSTRUCTION_OPCODE_WIDTH - 1 downto 0);
begin
	opcode <= instruction
		(MIPS_CPU_INSTRUCTION_OPCODE_HI downto MIPS_CPU_INSTRUCTION_OPCODE_LO);
end architecture;
