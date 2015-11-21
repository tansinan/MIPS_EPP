library ieee;
use ieee.std_logic_1164.all;
use work.MIPSCPU.all;

entity TypeJInstructionDecoder is
	port (
		instruction : in std_logic_vector(MIPS_CPU_INSTRUCTION_WIDTH - 1 downto 0);
		result : out InstructionDecodingResult_t
	);
end TypeJInstructionDecoder;

architecture Behavioral of TypeJInstructionDecoder is

begin


end Behavioral;

